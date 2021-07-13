require "isodoc"
require_relative "sections"
require "fileutils"

module IsoDoc
  module Iso
    module BaseConvert
      def convert1(docxml, filename, dir)
        if amd(docxml)
          @oldsuppressheadingnumbers = @suppressheadingnumbers
          @suppressheadingnumbers = true
        end
        super
      end

      def implicit_reference(bib)
        return true if bib&.at(ns("./docidentifier"))&.text == "IEV"

        super
      end

      # terms not defined in standoc
      def error_parse(node, out)
        case node.name
        when "appendix" then clause_parse(node, out)
        else
          super
        end
      end

      def example_span_label(_node, div, name)
        return if name.nil?

        div.span **{ class: "example_label" } do |p|
          name.children.each { |n| parse(n, p) }
        end
      end

      def example_p_parse(node, div)
        name = node&.at(ns("./name"))&.remove
        div.p do |p|
          example_span_label(node, p, name)
          insert_tab(p, 1)
          node.first_element_child.children.each { |n| parse(n, p) }
        end
        node.element_children[1..-1].each { |n| parse(n, div) }
      end

      def example_parse1(node, div)
        div.p do |p|
          example_span_label(node, p, node.at(ns("./name")))
          insert_tab(p, 1)
        end
        node.children.each { |n| parse(n, div) unless n.name == "name" }
      end

      def node_begins_with_para(node)
        node.elements.each do |e|
          next if e.name == "name"
          return true if e.name == "p"

          return false
        end
        false
      end

      def example_parse(node, out)
        out.div **{ id: node["id"], class: "example" } do |div|
          if node_begins_with_para(node)
            example_p_parse(node, div)
          else
            example_parse1(node, div)
          end
        end
      end

      def insertall_after_here(node, insert, name)
        node.children.each do |n|
          next unless n.name == name

          insert.next = n.remove
          insert = n
        end
        insert
      end

      def termexamples_before_termnotes(node)
        return unless node.at(ns("./termnote")) && node.at(ns("./termexample"))
        return unless insert = node.at(ns("./definition"))

        insert = insertall_after_here(node, insert, "termexample")
        insertall_after_here(node, insert, "termnote")
      end

      def termdef_parse(node, out)
        termexamples_before_termnotes(node)
        super
      end

      def cleanup(docxml)
        super
        table_th_center(docxml)
        docxml
      end

      def table_th_center(docxml)
        docxml.xpath("//thead//th | //thead//td").each do |th|
          th["align"] = "center"
          th["valign"] = "middle"
        end
      end

      def formula_where(dlist, out)
        return if dlist.nil?
        return super unless dlist&.xpath(ns("./dt"))&.size == 1 &&
          dlist&.at(ns("./dd"))&.elements&.size == 1 &&
          dlist&.at(ns("./dd/p"))

        out.span **{ class: "zzMoveToFollowing" } do |s|
          s << "#{@i18n.where} "
          dlist.at(ns("./dt")).children.each { |n| parse(n, s) }
          s << " "
        end
        parse(dlist.at(ns("./dd/p")), out)
      end

      def admonition_parse(node, out)
        type = node["type"]
        name = admonition_name(node, type)
        out.div **{ id: node["id"], class: admonition_class(node) } do |div|
          if node.first_element_child.name == "p"
            admonition_p_parse(node, div, name)
          else
            admonition_parse1(node, div, name)
          end
        end
      end

      def admonition_parse1(node, div, name)
        div.p do |p|
          admonition_name_parse(node, p, name) if name
        end
        node.children.each { |n| parse(n, div) unless n.name == "name" }
      end

      def admonition_p_parse(node, div, name)
        div.p do |p|
          admonition_name_parse(node, p, name) if name
          node.first_element_child.children.each { |n| parse(n, p) }
        end
        node.element_children[1..-1].each { |n| parse(n, div) }
      end

      def admonition_name_parse(_node, div, name)
        name.children.each { |n| parse(n, div) }
        div << " &mdash; "
      end

      def figure_name_parse(_node, div, name)
        div.p **{ class: "FigureTitle", style: "text-align:center;" } do |p|
          name&.children&.each { |n| parse(n, p) }
        end
      end

      def middle(isoxml, out)
        middle_title(isoxml, out)
        middle_admonitions(isoxml, out)
        i = scope isoxml, out, 0
        i = norm_ref isoxml, out, i
        # i = terms_defs isoxml, out, i
        # symbols_abbrevs isoxml, out, i
        clause_etc isoxml, out, i
        annex isoxml, out
        bibliography isoxml, out
        indexsect isoxml, out
      end

      def clause_etc(isoxml, out, num)
        isoxml.xpath(ns("//sections/clause[not(@type = 'scope')] | "\
                        "//sections/terms | //sections/definitions")).each do |f|
          out.div **attr_code(id: f["id"],
                              class: f.name == "definitions" ? "Symbols" : nil) do |div|
            num = num + 1
            clause_name(num, f&.at(ns("./title")), div, nil)
            f.elements.each do |e|
              parse(e, div) unless %w{title source}.include? e.name
            end
          end
        end
      end

      def indexsect(isoxml, out)
        isoxml.xpath(ns("//indexsect")).each do |i|
          clause_parse(i, out)
        end
      end
    end
  end
end
