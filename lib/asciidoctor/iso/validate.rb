require "metanorma-standoc"
require_relative "./validate_style"
require_relative "./validate_requirements"
require_relative "./validate_section"
require_relative "./validate_title"
require_relative "./validate_image"
require "nokogiri"
require "jing"
require "iev"

module Asciidoctor
  module ISO
    class Converter < Standoc::Converter
      def isosubgroup_validate(root)
        root.xpath("//technical-committee/@type").each do |t|
          unless %w{TC PC JTC JPC}.include? t.text
            @log.add("Document Attributes", nil,
                     "invalid technical committee type #{t}")
          end
        end
        root.xpath("//subcommittee/@type").each do |t|
          unless %w{SC JSC}.include? t.text
            @log.add("Document Attributes", nil,
                     "invalid subcommittee type #{t}")
          end
        end
      end

      # ISO/IEC DIR 2, 15.5.3
      # does not deal with preceding text marked up
      def see_xrefs_validate(root)
        root.xpath("//xref").each do |t|
          preceding = t.at("./preceding-sibling::text()[last()]")
          next unless !preceding.nil? &&
            /\b(see| refer to)\s*\Z/mi.match(preceding)

          (target = root.at("//*[@id = '#{t['target']}']")) || next
          if target&.at("./ancestor-or-self::*[@obligation = 'normative']")
            @log.add("Style", t,
                     "'see #{t['target']}' is pointing to a normative section")
          end
        end
      end

      # ISO/IEC DIR 2, 15.5.3
      def see_erefs_validate(root)
        root.xpath("//eref").each do |t|
          prec = t.at("./preceding-sibling::text()[last()]")
          next unless !prec.nil? && /\b(see|refer to)\s*\Z/mi.match(prec)

          unless target = root.at("//*[@id = '#{t['bibitemid']}']")
            @log.add("Bibliography", t,
                     "'#{t} is not pointing to a real reference")
            next
          end
          target.at("./ancestor::references[@normative = 'true']") and
            @log.add("Style", t,
                     "'see #{t}' is pointing to a normative reference")
        end
      end

      # ISO/IEC DIR 2, 10.4
      def locality_erefs_validate(root)
        root.xpath("//eref[descendant::locality]").each do |t|
          if /^(ISO|IEC)/.match?(t["citeas"]) &&
              !(/: ?(\d+{4}|–)$/.match?(t["citeas"]))
            @log.add("Style", t,
                     "undated reference #{t['citeas']} should not contain "\
                     "specific elements")
          end
        end
      end

      def termdef_warn(text, regex, elem, term, msg)
        regex.match(text) && @log.add("Style", elem, "#{term}: #{msg}")
      end

      # ISO/IEC DIR 2, 16.5.6
      def termdef_style(xmldoc)
        xmldoc.xpath("//term").each do |t|
          para = t.at("./definition") || return
          term = t.at("./preferred").text
          termdef_warn(para.text, /\A(the|a)\b/i, t, term,
                       "term definition starts with article")
          termdef_warn(para.text, /\.\Z/i, t, term,
                       "term definition ends with period")
        end
      end

      def doctype_validate(xmldoc)
        doctype = xmldoc&.at("//bibdata/ext/doctype")&.text
        %w(international-standard technical-specification technical-report
        publicly-available-specification international-workshop-agreement
        guide amendment technical-corrigendum).include? doctype or
        @log.add("Document Attributes", nil,
                 "#{doctype} is not a recognised document type")
      end

      def script_validate(xmldoc)
        script = xmldoc&.at("//bibdata/script")&.text
        script == "Latn" or
          @log.add("Document Attributes", nil,
                   "#{script} is not a recognised script")
      end

      def stage_validate(xmldoc)
        stage = xmldoc&.at("//bibdata/status/stage")&.text
        %w(00 10 20 30 40 50 60 90 95).include? stage or
          @log.add("Document Attributes", nil,
                   "#{stage} is not a recognised stage")
      end

      def substage_validate(xmldoc)
        substage = xmldoc&.at("//bibdata/status/substage")&.text or return
        %w(00 20 60 90 92 93 98 99).include? substage or
          @log.add("Document Attributes", nil,
                   "#{substage} is not a recognised substage")
      end

      def iteration_validate(xmldoc)
        iteration = xmldoc&.at("//bibdata/status/iteration")&.text or return
        /^\d+/.match(iteration) or
          @log.add("Document Attributes", nil,
                   "#{iteration} is not a recognised iteration")
      end

      def bibdata_validate(doc)
        doctype_validate(doc)
        script_validate(doc)
        stage_validate(doc)
        substage_validate(doc)
        iteration_validate(doc)
      end

      def content_validate(doc)
        super
        title_validate(doc.root)
        isosubgroup_validate(doc.root)
        onlychild_clause_validate(doc.root)
        termdef_style(doc.root)
        see_xrefs_validate(doc.root)
        see_erefs_validate(doc.root)
        locality_erefs_validate(doc.root)
        bibdata_validate(doc.root)
        bibitem_validate(doc.root)
        figure_validate(doc.root)
      end

      def bibitem_validate(xmldoc)
        xmldoc.xpath("//bibitem[date/on = '–']").each do |b|
          b.at("./note[@type = 'Unpublished-Status']") or
            @log.add("Style", b,
                     "Reference #{b&.at('./@id')&.text} does not have an "\
                     "associated footnote indicating unpublished status")
        end
      end

      def validate(doc)
        content_validate(doc)
        doctype = doc&.at("//bibdata/ext/doctype")&.text
        schema = case doctype
                 when "amendment", "technical-corrigendum" # @amd
                   "isostandard-amd.rng"
                 else
                   "isostandard.rng"
                 end
        schema_validate(formattedstr_strip(doc.dup),
                        File.join(File.dirname(__FILE__), schema))
      end
    end
  end
end
