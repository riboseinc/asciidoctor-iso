module IsoDoc
  module Iso
    class Counter < IsoDoc::XrefGen::Counter
    end

    class Xref < IsoDoc::Xref
      def initial_anchor_names(doc)
        if @klass.amd(doc)
          initial_anchor_names_amd(doc)
        else
          initial_anchor_names1(doc)
        end
        introduction_names(doc.at(ns("//introduction")))
      end

      def initial_anchor_names_amd(doc)
        doc.xpath(ns("//preface/*")).each do |c|
          c.element? and preface_names(c)
        end
        sequential_asset_names(doc.xpath(ns("//preface/*")))
        doc.xpath(ns("//sections/clause")).each do |c|
          c.element? and preface_names(c)
        end
        middle_section_asset_names(doc)
        termnote_anchor_names(doc)
        termexample_anchor_names(doc)
      end

      def initial_anchor_names1(doc)
        doc.xpath(ns("//preface/*")).each { |c| c.element? and preface_names(c) }
        # potentially overridden in middle_section_asset_names()
        sequential_asset_names(doc.xpath(ns("//preface/*")))
        n = Counter.new
        n = section_names(doc.at(ns("//clause[@type = 'scope']")), n, 1)
        n = section_names(doc.at(ns(@klass.norm_ref_xpath)), n, 1)
        doc.xpath(ns("//sections/clause[not(@type = 'scope')] | "\
                     "//sections/terms | //sections/definitions")).each do |c|
          n = section_names(c, n, 1)
        end
        middle_section_asset_names(doc)
        termnote_anchor_names(doc)
        termexample_anchor_names(doc)
      end

      # we can reference 0-number clauses in introduction
      def introduction_names(clause)
        return if clause.nil?

        clause.at(ns("./clause")) and
          @anchors[clause["id"]] = { label: "0", level: 1, type: "clause",
                                     xref: clause.at(ns("./title"))&.text }
        i = Counter.new
        clause.xpath(ns("./clause")).each do |c|
          i.increment(c)
          section_names1(c, "0.#{i.print}", 2)
        end
      end

      def annex_names(clause, num)
        appendix_names(clause, num)
        super
      end

      def appendix_names(clause, _num)
        i = Counter.new
        clause.xpath(ns("./appendix")).each do |c|
          i.increment(c)
          @anchors[c["id"]] = anchor_struct(i.print, nil, @labels["appendix"],
                                            "clause")
          @anchors[c["id"]][:level] = 2
          @anchors[c["id"]][:container] = clause["id"]
          j = Counter.new
          c.xpath(ns("./clause | ./references")).each do |c1|
            j.increment(c1)
            lbl = "#{@labels['appendix']} #{i.print}.#{j.print}"
            appendix_names1(c1, l10n(lbl), 3, clause["id"])
          end
        end
      end

      def section_names1(clause, num, level)
        @anchors[clause["id"]] =
          { label: num, level: level, xref: num }
        # subclauses are not prefixed with "Clause"
        i = Counter.new
        clause.xpath(ns("./clause | ./terms | ./term | ./definitions | "\
                        "./references"))
          .each do |c|
          i.increment(c)
          section_names1(c, "#{num}.#{i.print}", level + 1)
        end
      end

      def annex_names1(clause, num, level)
        @anchors[clause["id"]] = { label: num, xref: num, level: level }
        i = Counter.new
        clause.xpath(ns("./clause | ./references")).each do |c|
          i.increment(c)
          annex_names1(c, "#{num}.#{i.print}", level + 1)
        end
      end

      def appendix_names1(clause, num, level, container)
        @anchors[clause["id"]] = { label: num, xref: num, level: level,
                                   container: container }
        i = Counter.new
        clause.xpath(ns("./clause | ./references")).each do |c|
          i.increment(c)
          appendix_names1(c, "#{num}.#{i.print}", level + 1, container)
        end
      end

      def hierarchical_formula_names(clause, num)
        c = IsoDoc::XrefGen::Counter.new
        clause.xpath(ns(".//formula")).each do |t|
          next if t["id"].nil? || t["id"].empty?

          @anchors[t["id"]] = anchor_struct(
            "#{num}#{hiersep}#{c.increment(t).print}", t,
            t["inequality"] ? @labels["inequality"] : @labels["formula"],
            "formula", t["unnumbered"]
          )
        end
      end

      def figure_anchor(elem, sublabel, label)
        @anchors[elem["id"]] = anchor_struct(
          (sublabel ? "#{label} #{sublabel}" : label),
          nil, @labels["figure"], "figure", elem["unnumbered"]
        )
        sublabel && elem["unnumbered"] != "true" and
          @anchors[elem["id"]][:label] = sublabel
      end

      def sequential_figure_names(clause)
        c = IsoDoc::XrefGen::Counter.new
        j = 0
        clause.xpath(ns(".//figure | .//sourcecode[not(ancestor::example)]"))
          .each do |t|
          j = subfigure_increment(j, c, t)
          sublabel = j.zero? ? nil : "#{(j + 96).chr})"
          next if t["id"].nil? || t["id"].empty?

          figure_anchor(t, sublabel, c.print)
        end
      end

      def hierarchical_figure_names(clause, num)
        c = IsoDoc::XrefGen::Counter.new
        j = 0
        clause.xpath(ns(".//figure |  .//sourcecode[not(ancestor::example)]"))
          .each do |t|
          j = subfigure_increment(j, c, t)
          label = "#{num}#{hiersep}#{c.print}"
          sublabel = j.zero? ? nil : "#{(j + 96).chr})"
          next if t["id"].nil? || t["id"].empty?

          figure_anchor(t, sublabel, label)
        end
      end

      def reference_names(ref)
        super
        @anchors[ref["id"]] = { xref: @anchors[ref["id"]][:xref]
          .sub(/ \(All Parts\)/i, "") }
      end

      def back_anchor_names(docxml)
        super
        docxml.xpath(ns("//indexsect")).each { |b| preface_names(b) }
      end
    end
  end
end
