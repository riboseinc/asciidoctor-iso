require "spec_helper"

RSpec.describe Asciidoctor::ISO do
  it "processes sections" do
    input = <<~INPUT
      #{ASCIIDOC_BLANK_HDR}
      == Foreword

      Text

      == Introduction

      === Introduction Subsection

      == Scope

      Text

      == Acknowledgements

      == Normative References

      == Terms and Definitions

      === Term1

      == Terms, Definitions, Symbols and Abbreviated Terms

      === Normal Terms

      ==== Term2

      === Symbols and Abbreviated Terms

      == Symbols and Abbreviated Terms

      == Clause 4

      === Introduction

      === Clause 4.2

      == Terms and Definitions

      [appendix]
      == Annex

      === Annex A.1

      [%appendix]
      === Appendix 1

      ==== Appendix subclause

      == Bibliography

      === Bibliography Subsection
    INPUT
    output = <<~OUTPUT
      #{BLANK_HDR}
        <preface>
          <foreword id="_" obligation="informative">
            <title>Foreword</title>
            <p id="_">Text</p>
          </foreword>
          <introduction id="_" obligation="informative">
            <title>Introduction</title>
            <clause id="_" inline-header="false" obligation="informative">
              <title>Introduction Subsection</title>
            </clause>
          </introduction>
          <acknowledgements id="_" obligation="informative">
            <title>Acknowledgements</title>
          </acknowledgements>
        </preface>
        <sections>
          <clause id="_" inline-header="false" obligation="normative" type="scope">
            <title>Scope</title>
            <p id="_">Text</p>
          </clause>
          <terms id="_" obligation="normative">
            <title>Terms and definitions</title>
            <p id="_">For the purposes of this document, the following terms and definitions apply.</p>
            <p id="_">ISO and IEC maintain terminological databases for use in standardization at the following addresses:</p>
            <ul id="_">
              <li>
                <p id="_">ISO Online browsing platform: available at

                  <link target="http://www.iso.org/obp"/></p>
              </li>
              <li>
                <p id="_">IEC Electropedia: available at

                  <link target="http://www.electropedia.org"/></p>
              </li>
            </ul>
            <term id="term-term1">
              <preferred>Term1</preferred>
            </term>
          </terms>
          <clause id="_" obligation="normative">
            <title>Terms, definitions, symbols and abbreviated terms</title>
            <terms id="_" obligation="normative">
              <title>Normal Terms</title>
              <term id="term-term2">
                <preferred>Term2</preferred>
              </term>
            </terms>
            <definitions id="_" obligation="normative">
              <title>Symbols and abbreviated terms</title>
            </definitions>
          </clause>
          <definitions id="_" obligation="normative">
            <title>Symbols and abbreviated terms</title>
          </definitions>
          <clause id="_" inline-header="false" obligation="normative">
            <title>Clause 4</title>
            <clause id="_" inline-header="false" obligation="normative">
              <title>Introduction</title>
            </clause>
            <clause id="_" inline-header="false" obligation="normative">
              <title>Clause 4.2</title>
            </clause>
          </clause>
          <clause id="_" inline-header="false" obligation="normative">
            <title>Terms and Definitions</title>
          </clause>
        </sections>
        <annex id="_" inline-header="false" obligation="normative">
          <title>Annex</title>
          <clause id="_" inline-header="false" obligation="normative">
            <title>Annex A.1</title>
          </clause>
          <appendix id="_" inline-header="false" obligation="normative">
            <title>Appendix 1</title>
            <clause id="_" inline-header="false" obligation="normative">
              <title>Appendix subclause</title>
            </clause>
          </appendix>
        </annex>
        <bibliography>
          <references id="_" normative="true" obligation="informative">
            <title>Normative references</title>
            <p id="_">There are no normative references in this document.</p>
          </references>
          <clause id="_" obligation="informative">
            <title>Bibliography</title>
            <references id="_" normative="false" obligation="informative">
              <title>Bibliography Subsection</title>
            </references>
          </clause>
        </bibliography>
      </iso-standard>
    OUTPUT
    expect(xmlpp(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to xmlpp(output)
  end

  it "processes section obligations" do
    input = <<~INPUT
      #{ASCIIDOC_BLANK_HDR}
      [obligation=informative]
      == Clause 1

      === Clause 1a

      [obligation=normative]
      == Clause 2

      [appendix,obligation=informative]
      == Annex
    INPUT
    output = <<~OUTPUT
      #{BLANK_HDR}
        <sections>
          <clause id="_" inline-header="false" obligation="informative">
            <title>Clause 1</title>
            <clause id="_" inline-header="false" obligation="informative">
              <title>Clause 1a</title>
            </clause>
          </clause>
          <clause id="_" inline-header="false" obligation="normative">
            <title>Clause 2</title>
          </clause>
        </sections>
        <annex id="_" inline-header="false" obligation="informative">
          <title>Annex</title>
        </annex>
      </iso-standard>
    OUTPUT
    expect(xmlpp(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to xmlpp(output)
  end

  it "processes inline headers" do
    input = <<~INPUT
      #{ASCIIDOC_BLANK_HDR}
      == Clause 1

      [%inline-header]
      === Clause 1a

      [appendix]
      == Annex A

      [%inline-header]
      === Clause Aa
    INPUT
    output = <<~OUTPUT
      #{BLANK_HDR}
        <sections>
          <clause id="_" inline-header="false" obligation="normative">
            <title>Clause 1</title>
            <clause id="_" inline-header="true" obligation="normative">
              <title>Clause 1a</title>
            </clause>
          </clause>
        </sections>
        <annex id="_" inline-header="false" obligation="normative">
          <title>Annex A</title>
          <clause id="_" inline-header="true" obligation="normative">
            <title>Clause Aa</title>
          </clause>
        </annex>
      </iso-standard>
    OUTPUT
    expect(xmlpp(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to xmlpp(output)
  end

  it "processes blank headers" do
    input = <<~INPUT
      #{ASCIIDOC_BLANK_HDR}
      == Clause 1

      === {blank}

    INPUT
    output = <<~OUTPUT
      #{BLANK_HDR}
        <sections>
          <clause id="_" inline-header="false" obligation="normative">
            <title>Clause 1</title>
            <clause id="_" inline-header="false" obligation="normative"/>
          </clause>
        </sections>
      </iso-standard>
    OUTPUT
    expect(xmlpp(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to xmlpp(output)
  end

  it "processes terms & definitions with external source" do
    input = <<~INPUT
      #{ASCIIDOC_BLANK_HDR}

      Foreword

      [source="iso1234,iso5678"]
      == Terms and Definitions

      === Term1

    INPUT
    output = <<~OUTPUT
        #{BLANK_HDR.sub(/<boilerplate>/, '<termdocsource bibitemid="iso1234"/><termdocsource bibitemid="iso5678"/><boilerplate>')}
        <preface>
          <foreword id="_" obligation="informative">
            <title>Foreword</title>
            <p id="_">Foreword</p>
          </foreword>
        </preface>
        <sections>
          <terms id="_" obligation="normative">
            <title>Terms and definitions</title>
            <p id="_">For the purposes of this document, the terms and definitions
              given in <eref bibitemid="iso1234"/>
              and <eref bibitemid="iso5678"/>
              and the following apply.</p>
            <p id="_">ISO and IEC maintain terminological databases for use in
        standardization at the following addresses:</p>
            <ul id="_">
              <li>
                <p id="_">ISO Online browsing platform: available at

                  <link target="http://www.iso.org/obp"/></p>
              </li>
              <li>
                <p id="_">IEC Electropedia: available at

                  <link target="http://www.electropedia.org"/></p>
              </li>
            </ul>
            <term id="term-term1">
              <preferred>Term1</preferred>
            </term>
          </terms>
        </sections>
      </iso-standard>
    OUTPUT
    expect(xmlpp(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to xmlpp(output)
  end

  it "processes empty terms & definitions" do
    input = <<~INPUT
      #{ASCIIDOC_BLANK_HDR}

      Foreword

      == Terms and Definitions


    INPUT
    output = <<~OUTPUT
      #{BLANK_HDR}
        <preface>
          <foreword id="_" obligation="informative">
            <title>Foreword</title>
            <p id="_">Foreword</p>
          </foreword>
        </preface>
        <sections>
          <terms id='_' obligation='normative'>
            <title>Terms and definitions</title>
            <p id='_'>No terms and definitions are listed in this document.</p>
            <p id='_'>
              ISO and IEC maintain terminological databases for use in standardization
              at the following addresses:
            </p>
            <ul id='_'>
              <li>
                <p id='_'>
                  ISO Online browsing platform: available at
                  <link target='http://www.iso.org/obp'/>
                </p>
              </li>
              <li>
                <p id='_'>
                  IEC Electropedia: available at
                  <link target='http://www.electropedia.org'/>
                </p>
              </li>
            </ul>
          </terms>
        </sections>
      </iso-standard>

    OUTPUT
    expect(xmlpp(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to xmlpp(output)
  end

  it "processes empty terms & definitions with external source" do
    input = <<~INPUT
      #{ASCIIDOC_BLANK_HDR}

      Foreword

      [source="iso1234,iso5678"]
      == Terms and Definitions

    INPUT
    output = <<~OUTPUT
      #{BLANK_HDR.sub(/<boilerplate>/, '<termdocsource bibitemid="iso1234"/><termdocsource bibitemid="iso5678"/><boilerplate>')}
        <preface>
          <foreword id="_" obligation="informative">
            <title>Foreword</title>
            <p id="_">Foreword</p>
          </foreword>
        </preface>
        <sections>
          <terms id="_" obligation="normative">
            <title>Terms and definitions</title>
            <p id="_">For the purposes of this document,
              the terms and definitions given in <eref bibitemid="iso1234"/>
              and <eref bibitemid="iso5678"/>
              apply.
            </p>
            <p id="_">ISO and IEC maintain terminological databases for use in standardization at the following addresses:</p>
            <ul id="_">
              <li>
                <p id="_">ISO Online browsing platform: available at

                  <link target="http://www.iso.org/obp"/></p>
              </li>
              <li>
                <p id="_">IEC Electropedia: available at

                  <link target="http://www.electropedia.org"/></p>
              </li>
            </ul>
          </terms>
        </sections>
      </iso-standard>
    OUTPUT
    expect(xmlpp(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to xmlpp(output)
  end

  it "ignores multiple terms & definitions in default documents" do
    input = <<~INPUT
      #{ASCIIDOC_BLANK_HDR}

      == Terms and Definitions

      == Clause

      [heading=terms and definitions]
      == More terms

    INPUT
    output = <<~OUTPUT
      #{BLANK_HDR}
               <sections>
           <terms id='_' obligation='normative'>
             <title>Terms and definitions</title>
             <p id='_'>No terms and definitions are listed in this document.</p>
             <p id='_'>
               ISO and IEC maintain terminological databases for use in standardization
               at the following addresses:
             </p>
             <ul id='_'>
               <li>
                 <p id='_'>
                   ISO Online browsing platform: available at
                   <link target='http://www.iso.org/obp'/>
                 </p>
               </li>
               <li>
                 <p id='_'>
                   IEC Electropedia: available at
                   <link target='http://www.electropedia.org'/>
                 </p>
               </li>
             </ul>
           </terms>
           <clause id='_' inline-header='false' obligation='normative'>
             <title>Clause</title>
           </clause>
           <clause id='_' inline-header='false' obligation='normative'>
             <title>More terms</title>
           </clause>
         </sections>
       </iso-standard>
    OUTPUT
    expect(xmlpp(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to xmlpp(output)
  end

  it "permits multiple terms & definitions in vocabulary documents" do
    input = <<~INPUT
      #{ASCIIDOC_BLANK_HDR.sub(/:nodoc:/, ":nodoc:\n:docsubtype: vocabulary")}

      == Terms and Definitions

      == Clause

      [heading=terms and definitions]
      == More terms

    INPUT
    output = <<~OUTPUT
      #{BLANK_HDR.sub(%r{<doctype>article</doctype>}, "<doctype>article</doctype><subdoctype>vocabulary</subdoctype>")}
               <sections>
           <terms id='_' obligation='normative'>
             <title>Terms and definitions</title>
             <p id='_'>No terms and definitions are listed in this document.</p>
             <p id='_'>
               ISO and IEC maintain terminological databases for use in standardization
               at the following addresses:
             </p>
             <ul id='_'>
               <li>
                 <p id='_'>
                   ISO Online browsing platform: available at
                   <link target='http://www.iso.org/obp'/>
                 </p>
               </li>
               <li>
                 <p id='_'>
                   IEC Electropedia: available at
                   <link target='http://www.electropedia.org'/>
                 </p>
               </li>
             </ul>
           </terms>
           <clause id='_' inline-header='false' obligation='normative'>
             <title>Clause</title>
           </clause>
           <terms id='_' obligation='normative'>
             <title>More terms</title>
           </terms>
         </sections>
       </iso-standard>
    OUTPUT
    expect(xmlpp(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to xmlpp(output)
  end
end
