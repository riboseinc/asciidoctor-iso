require "date"
require "nokogiri"
require "htmlentities"
require "json"
require "pathname"

module Asciidoctor
  module ISO
    class Converter < Standoc::Converter
      PRE_NORMREF_FOOTNOTES = "//preface//fn | "\
        "//clause[@type = 'scope']//fn".freeze

      NORMREF_FOOTNOTES =
        "//references[@normative = 'true']//fn".freeze

      POST_NORMREF_FOOTNOTES =
        "//sections//clause[not(@type = 'scope')]//fn | "\
        "//annex//fn | "\
        "//references[@normative = 'false']//fn".freeze

      def other_footnote_renumber(xmldoc)
        seen = {}
        i = 0
        [PRE_NORMREF_FOOTNOTES, NORMREF_FOOTNOTES,
         POST_NORMREF_FOOTNOTES].each do |xpath|
          xmldoc.xpath(xpath).each do |fn|
            i, seen = other_footnote_renumber1(fn, i, seen)
          end
        end
      end

      def id_prefix(prefix, id)
        # we're just inheriting the prefixes from parent doc
        return id.text if @amd

        prefix.join("/") + (id.text.match?(%{^/}) ? "" : " ") + id.text
      end

      def get_id_prefix(xmldoc)
        prefix = []
        xmldoc.xpath("//bibdata/contributor[role/@type = 'publisher']"\
                     "/organization").each do |x|
          x1 = x.at("abbreviation")&.text || x.at("name")&.text
          x1 == "ISO" and prefix.unshift("ISO") or prefix << x1
        end
        prefix
      end

      # ISO as a prefix goes first
      def docidentifier_cleanup(xmldoc)
        prefix = get_id_prefix(xmldoc)
        id = xmldoc.at("//bibdata/docidentifier[@type = 'ISO']") or return
        id.content = id_prefix(prefix, id)
        id = xmldoc.at("//bibdata/ext/structuredidentifier/project-number") and
          id.content = id_prefix(prefix, id)
        id = xmldoc.at("//bibdata/docidentifier[@type = 'iso-with-lang']") and
          id.content = id_prefix(prefix, id)
        id = xmldoc.at("//bibdata/docidentifier[@type = 'iso-reference']") and
          id.content = id_prefix(prefix, id)
      end

      def format_ref(ref, type)
        ref = ref.sub(/ \(All Parts\)/i, "")
        super
      end

      TERM_CLAUSE = "//sections//terms | "\
        "//sections//clause[descendant::terms][not(descendant::definitions)]"
        .freeze

      PUBLISHER = "./contributor[role/@type = 'publisher']/organization".freeze

      OTHERIDS = "@type = 'DOI' or @type = 'metanorma' or @type = 'ISSN' or "\
        "@type = 'ISBN'".freeze

      def pub_class(bib)
        return 1 if bib.at("#{PUBLISHER}[abbreviation = 'ISO']")
        return 1 if bib.at("#{PUBLISHER}[name = 'International Organization "\
                           "for Standardization']")
        return 2 if bib.at("#{PUBLISHER}[abbreviation = 'IEC']")
        return 2 if bib.at("#{PUBLISHER}[name = 'International "\
                           "Electrotechnical Commission']")
        return 3 if bib.at("./docidentifier[@type][not(#{OTHERIDS})]")

        4
      end

      def sort_biblio(bib)
        bib.sort do |a, b|
          sort_biblio_key(a) <=> sort_biblio_key(b)
        end
      end

      # TODO sort by authors
      # sort by: doc class (ISO, IEC, other standard (not DOI &c), other
      # then standard class (docid class other than DOI &c)
      # then docnumber if present, numeric sort
      #      else alphanumeric metanorma id (abbreviation)
      # then doc part number if present, numeric sort
      # then doc id (not DOI &c)
      # then title
      def sort_biblio_key(bib)
        pubclass = pub_class(bib)
        num = bib&.at("./docnumber")&.text
        id = bib&.at("./docidentifier[not(#{OTHERIDS})]")
        metaid = bib&.at("./docidentifier[@type = 'metanorma']")&.text
        abbrid = metaid unless /^\[\d+\]$/.match?(metaid)
        /\d-(?<partid>\d+)/ =~ id&.text
        type = id["type"] if id
        title = bib&.at("./title[@type = 'main']")&.text ||
          bib&.at("./title")&.text || bib&.at("./formattedref")&.text
        "#{pubclass} :: #{type} :: "\
          "#{num.nil? ? abbrid : sprintf('%09d', num.to_i)} :: "\
          "#{partid} :: #{id&.text} :: #{title}"
      end

      def sections_cleanup(xml)
        super
        return unless @amd

        xml.xpath("//*[@inline-header]").each do |h|
          h.delete("inline-header")
        end
      end

      def boilerplate_file(_xmldoc)
        file = @lang == "fr" ? "boilerplate-fr.xml" : "boilerplate.xml"
        File.join(@libdir, file)
      end

      def footnote_cleanup(xmldoc)
        unpub_footnotes(xmldoc)
        super
      end

      def unpub_footnotes(xmldoc)
        xmldoc.xpath("//bibitem/note[@type = 'Unpublished-Status']").each do |n|
          id = n.parent["id"]
          e = xmldoc.at("//eref[@bibitemid = '#{id}']") or next
          e.next = n.dup
          e.next.name = "fn"
          e.next.delete("format")
          e.next.delete("type")
        end
      end

      def bibitem_cleanup(xmldoc)
        super
        unpublished_note(xmldoc)
      end

      def unpublished_note(xmldoc)
        xmldoc.xpath("//bibitem[not(note[@type = 'Unpublished-Status'])]")
          .each do |b|
          next if pub_class(b) > 2
          next unless (s = b.at("./status/stage")) && (s.text.to_i < 60)

          id = b.at("docidentifier").text
          b.at("./language | ./script | ./abstract | ./status")
            .previous = %(<note type="Unpublished-Status">
                          <p>#{@i18n.under_preparation.sub(/%/, id)}</p></note>)
        end
      end

      def termdef_boilerplate_insert(xmldoc, isodoc, once = false)
        once = true
        super
      end

      def term_defs_boilerplate_cont(src, term, isodoc)
        @vocab and src.empty? and return
        super
      end
    end
  end
end
