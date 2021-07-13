require "htmlentities"
require "uri"

module Asciidoctor
  module ISO
    class Converter < Standoc::Converter
      def clause_parse(attrs, xml, node)
        node.option? "appendix" and return appendix_parse(attrs, xml, node)
        super
      end

      def scope_parse(attrs, xml, node)
        attrs = attrs.merge(type: "scope") unless @amd
        clause_parse(attrs, xml, node)
      end

      def appendix_parse(attrs, xml, node)
        attrs["inline-header".to_sym] = node.option? "inline-header"
        set_obligation(attrs, node)
        xml.appendix **attr_code(attrs) do |xml_section|
          xml_section.title { |name| name << node.title }
          xml_section << node.content
        end
      end

      def patent_notice_parse(xml, node)
        # xml.patent_notice do |xml_section|
        #  xml_section << node.content
        # end
        xml << node.content
      end

      def sectiontype(node, level = true)
        return nil if @amd

        ret = sectiontype_streamline(sectiontype1(node))
        return ret if ret == "terms and definitions" && @vocab

        super
      end
    end
  end
end
