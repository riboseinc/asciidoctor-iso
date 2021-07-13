require "spec_helper"

RSpec.describe IsoDoc do
  it "processes section names" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
        <preface>
          <foreword obligation="informative">
            <title>Foreword</title>
            <p id="A">This is a preamble</p>
          </foreword>
          <introduction id="B" obligation="informative">
            <title>Introduction</title>
            <clause id="C" inline-header="false" obligation="informative">
              <title>Introduction Subsection</title>
            </clause>
            <p>This is patent boilerplate</p>
          </introduction>
        </preface>
        <sections>
          <clause id="D" obligation="normative" type="scope">
            <title>Scope</title>
            <p id="E">Text</p>
          </clause>
          <clause id="H" obligation="normative">
            <title>Terms, Definitions, Symbols and Abbreviated Terms</title>
            <terms id="I" obligation="normative">
              <title>Normal Terms</title>
              <term id="J">
                <preferred>Term2</preferred>
              </term>
            </terms>
            <definitions id="K">
              <dl>
                <dt>Symbol</dt>
                <dd>Definition</dd>
              </dl>
            </definitions>
          </clause>
          <definitions id="L">
            <dl>
              <dt>Symbol</dt>
              <dd>Definition</dd>
            </dl>
          </definitions>
          <clause id="M" inline-header="false" obligation="normative">
            <title>Clause 4</title>
            <clause id="N" inline-header="false" obligation="normative">
              <title>Introduction</title>
            </clause>
            <clause id="O" inline-header="false" obligation="normative">
              <title>Clause 4.2</title>
            </clause>
          </clause>
        </sections>
        <annex id="P" inline-header="false" obligation="normative">
          <title>Annex</title>
          <clause id="Q" inline-header="false" obligation="normative">
            <title>Annex A.1</title>
            <clause id="Q1" inline-header="false" obligation="normative">
              <title>Annex A.1a</title>
            </clause>
          </clause>
          <appendix id="Q2" inline-header="false" obligation="normative">
            <title>An Appendix</title>
            <clause id="Q2a" inline-header="false" obligation="normative">
              <title>Appendix subclause</title>
            </clause>
          </appendix>
          <references id="Q3" normative="false">
            <title>Annex Bibliography</title>
          </references>
        </annex>
        <bibliography>
          <references id="R" normative="true" obligation="informative">
            <title>Normative References</title>
          </references>
          <clause id="S" obligation="informative">
            <title>Bibliography</title>
            <references id="T" normative="false" obligation="informative">
              <title>Bibliography Subsection</title>
            </references>
          </clause>
        </bibliography>
      </iso-standard>
    INPUT

    presxml = <<~OUTPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml" type="presentation">
        <preface>
          <foreword obligation="informative" displayorder="1">
            <title>Foreword</title>
            <p id="A">This is a preamble</p>
          </foreword>
          <introduction id="B" obligation="informative" displayorder="2">
            <title depth="1">0<tab/>Introduction</title>
            <clause id="C" inline-header="false" obligation="informative">
              <title depth="2">0.1<tab/>Introduction Subsection</title>
            </clause>
            <p>This is patent boilerplate</p>
          </introduction>
        </preface>
        <sections>
          <clause id="D" obligation="normative" type="scope" displayorder="3">
            <title depth="1">1<tab/>Scope</title>
            <p id="E">Text</p>
          </clause>
          <clause id="H" obligation="normative" displayorder="5">
            <title depth="1">3<tab/>Terms, Definitions, Symbols and Abbreviated Terms</title>
            <terms id="I" obligation="normative">
              <title depth="2">3.1<tab/>Normal Terms</title>
              <term id="J"><name>3.1.1</name>
                <preferred>Term2</preferred>
              </term>
            </terms>
            <definitions id="K" inline-header="true"><title>3.2</title>
              <dl>
                <dt>Symbol</dt>
                <dd>Definition</dd>
              </dl>
            </definitions>
          </clause>
          <definitions id="L" displayorder="6"><title>4</title>
            <dl>
              <dt>Symbol</dt>
              <dd>Definition</dd>
            </dl>
          </definitions>
          <clause id="M" inline-header="false" obligation="normative" displayorder="7">
            <title depth="1">5<tab/>Clause 4</title>
            <clause id="N" inline-header="false" obligation="normative">
              <title depth="2">5.1<tab/>Introduction</title>
            </clause>
            <clause id="O" inline-header="false" obligation="normative">
              <title depth="2">5.2<tab/>Clause 4.2</title>
            </clause>
          </clause>
        </sections>
        <annex id="P" inline-header="false" obligation="normative" displayorder="8">
          <title><strong>Annex A</strong><br/>(normative)<br/><br/><strong>Annex</strong></title>
          <clause id="Q" inline-header="false" obligation="normative">
            <title depth="2">A.1<tab/>Annex A.1</title>
            <clause id="Q1" inline-header="false" obligation="normative">
              <title depth="3">A.1.1<tab/>Annex A.1a</title>
            </clause>
          </clause>
          <appendix id="Q2" inline-header="false" obligation="normative">
            <title depth="2">Appendix 1<tab/>An Appendix</title>
            <clause id="Q2a" inline-header="false" obligation="normative">
              <title depth="3">Appendix 1.1<tab/>Appendix subclause</title>
            </clause>
          </appendix>
          <references id="Q3" normative="false">
            <title depth="2">A.2<tab/>Annex Bibliography</title>
          </references>
        </annex>
        <bibliography>
          <references id="R" normative="true" obligation="informative" displayorder="4">
            <title depth="1">2<tab/>Normative References</title>
          </references>
          <clause id="S" obligation="informative" displayorder="9">
            <title depth="1">Bibliography</title>
            <references id="T" normative="false" obligation="informative">
              <title depth="2">Bibliography Subsection</title>
            </references>
          </clause>
        </bibliography>
      </iso-standard>
    OUTPUT

    html = <<~OUTPUT
      #{HTML_HDR}
            <br/>
            <div>
              <h1 class="ForewordTitle">Foreword</h1>
              <p id="A">This is a preamble</p>
            </div>
            <br/>
            <div class="Section3" id="B">
              <h1 class="IntroTitle">0&#160; Introduction</h1>
              <div id="C">
                <h2>0.1&#160; Introduction Subsection</h2>
              </div>
              <p>This is patent boilerplate</p>
            </div>
            <p class="zzSTDTitle1"/>
            <div id="D">
              <h1>1&#160; Scope</h1>
              <p id="E">Text</p>
            </div>
            <div>
              <h1>2&#160; Normative References</h1>
            </div>
            <div id="H">
              <h1>3&#160; Terms, Definitions, Symbols and Abbreviated Terms</h1>
              <div id="I">
                <h2>3.1&#160; Normal Terms</h2>
                <p class="TermNum" id="J">3.1.1</p>
                <p class="Terms" style="text-align:left;">Term2</p>
              </div>
              <div id="K">
                <span class="zzMoveToFollowing">
                  <b>3.2&#160; </b>
                </span>
                <dl>
                  <dt>
                    <p>Symbol</p>
                  </dt>
                  <dd>Definition</dd>
                </dl>
              </div>
            </div>
            <div class="Symbols" id="L">
              <h1>4</h1>
              <dl>
                <dt>
                  <p>Symbol</p>
                </dt>
                <dd>Definition</dd>
              </dl>
            </div>
            <div id="M">
              <h1>5&#160; Clause 4</h1>
              <div id="N">
                <h2>5.1&#160; Introduction</h2>
              </div>
              <div id="O">
                <h2>5.2&#160; Clause 4.2</h2>
              </div>
            </div>
            <br/>
            <div class="Section3" id="P">
              <h1 class="Annex">
                <b>Annex A</b>
                <br/>(normative)
                <br/>
                <br/>
                <b>Annex</b></h1>
              <div id="Q">
                <h2>A.1&#160; Annex A.1</h2>
                <div id="Q1">
                  <h3>A.1.1&#160; Annex A.1a</h3>
                </div>
              </div>
              <div id="Q2">
                <h2>Appendix 1&#160; An Appendix</h2>
                <div id="Q2a">
                  <h3>Appendix 1.1&#160; Appendix subclause</h3>
                </div>
              </div>
              <div>
                <h2 class="Section3">A.2&#160; Annex Bibliography</h2>
              </div>
            </div>
            <br/>
            <div>
              <h1 class="Section3">Bibliography</h1>
              <div>
                <h2 class="Section3">Bibliography Subsection</h2>
              </div>
            </div>
          </div>
        </body>
      </html>
    OUTPUT

    word = <<~OUTPUT
      <body lang="EN-US" link="blue" vlink="#954F72">
        <div class="WordSection1">
          <p>&#160;</p>
        </div>
        <p>
          <br class="section" clear="all"/>
        </p>
        <div class="WordSection2">
          <p>
            <br clear="all" style="mso-special-character:line-break;page-break-before:always"/>
          </p>
          <div>
            <h1 class="ForewordTitle">Foreword</h1>
            <p id="A" class='ForewordText'>This is a preamble</p>
          </div>
          <p>
            <br clear="all" style="mso-special-character:line-break;page-break-before:always"/>
          </p>
          <div class="Section3" id="B">
            <h1 class="IntroTitle">0
              <span style="mso-tab-count:1">&#160; </span>
              Introduction</h1>
            <div id="C">
              <h2>0.1
                <span style="mso-tab-count:1">&#160; </span>
                Introduction Subsection</h2>
            </div>
            <p>This is patent boilerplate</p>
          </div>
          <p>&#160;</p>
        </div>
        <p>
          <br class="section" clear="all"/>
        </p>
        <div class="WordSection3">
          <p class="zzSTDTitle1"/>
          <div id="D">
            <h1>1
              <span style="mso-tab-count:1">&#160; </span>
              Scope</h1>
            <p id="E">Text</p>
          </div>
          <div>
            <h1>2
              <span style="mso-tab-count:1">&#160; </span>
              Normative References</h1>
          </div>
          <div id="H">
            <h1>3
              <span style="mso-tab-count:1">&#160; </span>
              Terms, Definitions, Symbols and Abbreviated Terms</h1>
            <div id="I">
              <h2>3.1
                <span style="mso-tab-count:1">&#160; </span>
                Normal Terms</h2>
              <p class="TermNum" id="J">3.1.1</p>
              <p class="Terms" style="text-align:left;">Term2</p>
            </div>
            <div id="K">
              <span class="zzMoveToFollowing">
                <b>3.2
                  <span style="mso-tab-count:1">&#160; </span></b>
              </span>
              <table class="dl">
                <tr>
                  <td align="left" valign="top">
                    <p align="left" style="margin-left:0pt;text-align:left;">Symbol</p>
                  </td>
                  <td valign="top">Definition</td>
                </tr>
              </table>
            </div>
          </div>
          <div class="Symbols" id="L">
            <h1>4</h1>
            <table class="dl">
              <tr>
                <td align="left" valign="top">
                  <p align="left" style="margin-left:0pt;text-align:left;">Symbol</p>
                </td>
                <td valign="top">Definition</td>
              </tr>
            </table>
          </div>
          <div id="M">
            <h1>5
              <span style="mso-tab-count:1">&#160; </span>
              Clause 4</h1>
            <div id="N">
              <h2>5.1
                <span style="mso-tab-count:1">&#160; </span>
                Introduction</h2>
            </div>
            <div id="O">
              <h2>5.2
                <span style="mso-tab-count:1">&#160; </span>
                Clause 4.2</h2>
            </div>
          </div>
          <p>
            <br clear="all" style="mso-special-character:line-break;page-break-before:always"/>
          </p>
          <div class="Section3" id="P">
            <h1 class="Annex">
              <br/>(normative)
              <br/>
              <br/>
              <b>Annex</b></h1>
            <div id="Q">
              <h2>A.1
                <span style="mso-tab-count:1">&#160; </span>
                Annex A.1</h2>
              <div id="Q1">
                <h3>A.1.1
                  <span style="mso-tab-count:1">&#160; </span>
                  Annex A.1a</h3>
              </div>
            </div>
            <div id="Q2">
              <h2>Appendix 1
                <span style="mso-tab-count:1">&#160; </span>
                An Appendix</h2>
              <div id="Q2a">
                <h3>Appendix 1.1
                  <span style="mso-tab-count:1">&#160; </span>
                  Appendix subclause</h3>
              </div>
            </div>
            <div>
              <h2 class="BiblioTitle">A.2
                <span style="mso-tab-count:1">&#160; </span>
                Annex Bibliography</h2>
            </div>
          </div>
          <p>
            <br clear="all" style="mso-special-character:line-break;page-break-before:always"/>
          </p>
          <div>
            <h1 class="BiblioTitle">Bibliography</h1>
            <div>
              <h2 class="BiblioTitle">Bibliography Subsection</h2>
            </div>
          </div>
        </div>
        <br clear="all" style="page-break-before:left;mso-break-type:section-break"/>
        <div class="colophon"/>
      </body>
    OUTPUT
    expect(xmlpp(IsoDoc::Iso::PresentationXMLConvert.new({})
      .convert("test", input, true)))
      .to be_equivalent_to xmlpp(presxml)
    expect(xmlpp(IsoDoc::Iso::HtmlConvert.new({})
      .convert("test", presxml, true)))
      .to be_equivalent_to xmlpp(html)
    expect(xmlpp(IsoDoc::Iso::WordConvert.new({})
      .convert("test", presxml, true)
      .sub(/^.*<body /m, "<body ").sub(%r{</body>.*$}m, "</body>")))
      .to be_equivalent_to xmlpp(word)
  end

  it "processes subclauses with and without titles" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
        <sections>
          <clause id="D" obligation="normative">
            <title>Scope</title>
              <clause id="D1" obligation="normative">
                <title>Scope 1</title>
              </clause>
            <clause id="D2" obligation="normative">
            </clause>
          </clause>
        </sections>
      </iso-standard>
    INPUT

    presxml = <<~OUTPUT
      <iso-standard xmlns='http://riboseinc.com/isoxml' type="presentation">
        <sections>
          <clause id='D' obligation='normative' displayorder="1">
            <title depth='1'>1<tab/>Scope</title>
            <clause id='D1' obligation='normative'>
              <title depth='2'>1.1<tab/>Scope 1</title>
            </clause>
            <clause id='D2' obligation='normative' inline-header="true">
              <title>1.2</title>
            </clause>
          </clause>
        </sections>
      </iso-standard>
    OUTPUT

    html = <<~OUTPUT
      <html xmlns:epub='http://www.idpf.org/2007/ops' lang='en'>
        <head/>
        <body lang='en'>
          <div class='title-section'>
            <p>&#160;</p>
          </div>
          <br/>
          <div class='prefatory-section'>
            <p>&#160;</p>
          </div>
          <br/>
          <div class='main-section'>
            <p class='zzSTDTitle1'/>
            <div id='D'>
              <h1>1&#160; Scope</h1>
              <div id='D1'>
                <h2>1.1&#160; Scope 1</h2>
              </div>
              <div id='D2'>
                <span class='zzMoveToFollowing'>
                  <b>1.2&#160; </b>
                </span>
              </div>
            </div>
          </div>
        </body>
      </html>
    OUTPUT
    expect(xmlpp(IsoDoc::Iso::PresentationXMLConvert.new({})
      .convert("test", input, true)))
      .to be_equivalent_to xmlpp(presxml)
    expect(xmlpp(IsoDoc::Iso::HtmlConvert.new({})
      .convert("test", presxml, true)))
      .to be_equivalent_to xmlpp(html)
  end

  it "processes simple terms & definitions" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
        <sections>
          <terms id="H" obligation="normative">
            <title>Terms, Definitions, Symbols and Abbreviated Terms</title>
            <term id="J">
              <name>1.1</name>
              <preferred>Term2</preferred>
            </term>
          </terms>
        </sections>
      </iso-standard>
    INPUT
    output = <<~OUTPUT
      #{HTML_HDR}
            <p class="zzSTDTitle1"/>
            <div id="H">
              <h1>Terms, Definitions, Symbols and Abbreviated Terms</h1>
              <p class="TermNum" id="J">1.1</p>
              <p class="Terms" style="text-align:left;">Term2</p>
            </div>
          </div>
        </body>
      </html>
    OUTPUT
    expect(xmlpp(IsoDoc::Iso::HtmlConvert.new({})
      .convert("test", input, true))).to be_equivalent_to xmlpp(output)
  end

  it "processes multiple terms & definitions sections" do
    input = <<~INPUT
      #{BLANK_HDR.sub(%r{<doctype>article</doctype>}, '<doctype>article</doctype><subdoctype>vocabulary</subdoctype>')}
               <sections>
           <terms id='A' obligation='normative'>
             <title>Terms and definitions</title>
             <p id='A1'>No terms and definitions are listed in this document.</p>
           </terms>
           <clause id='B' inline-header='false' obligation='normative'>
             <title>Clause</title>
           </clause>
           <terms id='C' obligation='normative'>
             <title>More terms</title>
           </terms>
         </sections>
       </iso-standard>
    INPUT
    presxml = <<~OUTPUT
    <iso-standard xmlns='https://www.metanorma.org/ns/iso' type='presentation' version='1.8.6'>
         <bibdata type='standard'>
           <contributor>
             <role type='author'/>
             <organization>
               <name>International Organization for Standardization</name>
               <abbreviation>ISO</abbreviation>
             </organization>
           </contributor>
           <contributor>
             <role type='publisher'/>
             <organization>
               <name>International Organization for Standardization</name>
               <abbreviation>ISO</abbreviation>
             </organization>
           </contributor>
           <language current='true'>en</language>
           <script current='true'>Latn</script>
           <status>
             <stage abbreviation='IS' language=''>60</stage>
             <substage language=''>60</substage>
           </status>
           <copyright>
             <from>2021</from>
             <owner>
               <organization>
                 <name>International Organization for Standardization</name>
                 <abbreviation>ISO</abbreviation>
               </organization>
             </owner>
           </copyright>
           <ext>
             <doctype language=''>article</doctype>
             <subdoctype>vocabulary</subdoctype>
             <editorialgroup>
               <technical-committee/>
               <subcommittee/>
               <workgroup/>
             </editorialgroup>
             <stagename>International standard</stagename>
           </ext>
         </bibdata>
         <sections>
           <terms id='A' obligation='normative' displayorder='1'>
             <title depth='1'>
               1
               <tab/>
               Terms and definitions
             </title>
             <p id='A1'>No terms and definitions are listed in this document.</p>
           </terms>
           <clause id='B' inline-header='false' obligation='normative' displayorder='2'>
             <title depth='1'>
               2
               <tab/>
               Clause
             </title>
           </clause>
           <terms id='C' obligation='normative' displayorder='3'>
             <title depth='1'>
               3
               <tab/>
               More terms
             </title>
           </terms>
         </sections>
       </iso-standard>
    OUTPUT
    output = <<~OUTPUT
    <html lang='en'>
  <head/>
  <body lang='en'>
    <div class='title-section'>
      <p>&#160;</p>
    </div>
    <br/>
    <div class='prefatory-section'>
      <p>&#160;</p>
    </div>
    <br/>
    <div class='main-section'>
      <p class='zzSTDTitle1'/>
      <div id='A'>
        <h1> 1 &#160; Terms and definitions </h1>
        <p id='A1'>No terms and definitions are listed in this document.</p>
      </div>
      <div id='B'>
        <h1> 2 &#160; Clause </h1>
      </div>
      <div id='C'>
        <h1> 3 &#160; More terms </h1>
      </div>
    </div>
  </body>
</html>
    OUTPUT
    expect(xmlpp(IsoDoc::Iso::PresentationXMLConvert.new({})
      .convert("test", input, true)
      .gsub(%r{<localized-strings>.*</localized-strings>}m, "")
      .gsub(%r{<boilerplate>.*</boilerplate>}m, "")))
      .to be_equivalent_to xmlpp(presxml)
    expect(xmlpp(IsoDoc::Iso::HtmlConvert.new({})
      .convert("test", presxml, true))).to be_equivalent_to xmlpp(output)
  end

  it "processes inline section headers" do
    output = IsoDoc::Iso::HtmlConvert.new({}).convert("test", <<~"INPUT", true)
      <iso-standard xmlns="http://riboseinc.com/isoxml">
        <sections>
          <clause id="M" inline-header="false" obligation="normative">
            <title>Clause 4</title>
            <clause id="N" inline-header="false" obligation="normative">
              <title>Introduction</title>
            </clause>
            <clause id="O" inline-header="true" obligation="normative">
              <title>Clause 4.2</title>
              <p>Hello</p>
            </clause>
          </clause>
        </sections>
      </iso-standard>
    INPUT
    expect(xmlpp(output)).to be_equivalent_to xmlpp(<<~"OUTPUT")
      #{HTML_HDR}
            <p class="zzSTDTitle1"/>
            <div id="M">
              <h1>Clause 4</h1>
              <div id="N">
                <h2>Introduction</h2>
              </div>
              <div id="O">
                <span class="zzMoveToFollowing"><b>Clause 4.2&#160; </b></span>
                <p>Hello</p>
              </div>
            </div>
          </div>
        </body>
      </html>
    OUTPUT
  end

  it "adds colophon to published standard (Word)" do
    output = IsoDoc::Iso::WordConvert.new({}).convert("test", <<~"INPUT", true)
      <iso-standard xmlns="http://riboseinc.com/isoxml">
        <bibdata>
          <status>
            <stage>60</stage>
          </status>
        </bibdata>
        <sections/>
      </iso-standard>
    INPUT
    expect(xmlpp(output.sub(/^.*<body /m, "<body ").sub(%r{</body>.*$}m, "</body>")))
      .to be_equivalent_to xmlpp(<<~"OUTPUT")
        <body lang="EN-US" link="blue" vlink="#954F72">
          <div class="WordSection1">
            <p>&#160;</p>
          </div>
          <p><br clear="all" class="section"/></p>
          <div class="WordSection2">
            <p>&#160;</p>
          </div>
          <p><br clear="all" class="section"/></p>
          <div class="WordSection3">
            <p class="zzSTDTitle1"/>
          </div>
          <br clear="all" style="page-break-before:left;mso-break-type:section-break"/>
          <div class="colophon"/>
        </body>
      OUTPUT
  end

  it "does not add colophon to draft standard (Word)" do
    output = IsoDoc::Iso::WordConvert.new({}).convert("test", <<~"INPUT", true)
      <iso-standard xmlns="http://riboseinc.com/isoxml">
        <bibdata>
          <status>
            <stage>30</stage>
          </status>
        </bibdata>
        <sections/>
      </iso-standard>
    INPUT
    expect(xmlpp(output.sub(/^.*<body /m, "<body ").sub(%r{</body>.*$}m, "</body>")))
      .to be_equivalent_to xmlpp(<<~"OUTPUT")
        <body lang="EN-US" link="blue" vlink="#954F72">
          <div class="WordSection1">
            <p>&#160;</p>
          </div>
          <p><br clear="all" class="section"/></p>
          <div class="WordSection2">
            <p>&#160;</p>
          </div>
          <p><br clear="all" class="section"/></p>
          <div class="WordSection3">
            <p class="zzSTDTitle1"/>
          </div>
        </body>
      OUTPUT
  end

  it "processes middle title" do
    expect(xmlpp(IsoDoc::Iso::HtmlConvert.new({})
      .convert("test", <<~"INPUT", true))).to be_equivalent_to xmlpp(<<~"OUTPUT")
        <iso-standard xmlns="http://riboseinc.com/isoxml">
          <bibdata>
            <title format="text/plain" language="en" type="title-intro">Introduction</title>
            <title format="text/plain" language="en" type="title-main">Main Title — Title</title>
            <title format="text/plain" language="en" type="title-part">Title Part</title>
            <ext>
              <structuredidentifier>
                <project-number origyr="2016-05-01" part="1">17301</project-number>
              </structuredidentifier>
            </ext>
          </bibdata>
          <sections/>
        </iso-standard>
      INPUT
        #{HTML_HDR}
              <p class='zzSTDTitle1'>Introduction &#8212; Main Title&#8201;&#8212;&#8201;Title &#8212; </p>
              <p class='zzSTDTitle2'>
                Part&#160;1:
                <br/><b>Title Part</b>
              </p>
            </div>
          </body>
        </html>
      OUTPUT
  end

  it "generates an index in English" do
    input = <<~INPUT
      <iso-standard xmlns="https://open.ribose.com/standards/bipm">
        <bibdata>
          <language>en</language>
          <script>Latn</script>
        </bibdata>
        <sections>
          <clause id="A">
            <index><primary>&#xE9;long&#xE9;</primary></index>
            <index><primary>&#xEA;tre</primary><secondary>Husserl</secondary><tertiary>en allemand</tertiary></index>
            <index><primary><em>Eman</em>cipation</primary></index>
            <index><primary><em>Eman</em>cipation</primary><secondary>dans la France</secondary></index>
            <index><primary><em>Eman</em>cipation</primary><secondary>dans la France</secondary><tertiary>en Bretagne</tertiary></index>
            <clause id="B">
              <index><primary><em>Eman</em>cipation</primary></index>
              <index><primary>zebra</primary></index>
              <index><primary><em>Eman</em>cipation</primary><secondary>dans les &#xC9;tats-Unis</secondary></index>
              <index><primary><em>Eman</em>cipation</primary><secondary>dans la France</secondary><tertiary>&#xE0; Paris</tertiary></index>
              <index-xref also="true"><primary>&#xEA;tre</primary><secondary>Husserl</secondary><target>zebra</target></index-xref>
              <index-xref also="true"><primary>&#xEA;tre</primary><secondary>Husserl</secondary><target><em>Eman</em>cipation</target></index-xref>
              <index-xref also="false"><primary>&#xEA;tre</primary><secondary>Husserl</secondary><target>zebra</target></index-xref>
              <index-xref also="false"><primary><em>Dasein</em></primary><target>&#xEA;tre</target></index-xref>
              <index-xref also="false"><primary><em>Dasein</em></primary><target><em>Eman</em>cipation</target></index-xref>
            </clause>
          </clause>
        </sections>
      </bipm-standard>
    INPUT
    presxml = <<~OUTPUT
         <iso-standard xmlns='https://open.ribose.com/standards/bipm' type='presentation'>
        <bibdata>
          <language current='true'>en</language>
          <script current='true'>Latn</script>
        </bibdata>
        <sections>
          <clause id='A' displayorder="1">
            <title>1</title>
            <bookmark id='_'/>
            <bookmark id='_'/>
            <bookmark id='_'/>
            <bookmark id='_'/>
            <bookmark id='_'/>
            <clause id='B' inline-header='true'>
              <title>1.1</title>
              <bookmark id='_'/>
              <bookmark id='_'/>
              <bookmark id='_'/>
              <bookmark id='_'/>
            </clause>
          </clause>
        </sections>
        <indexsect id='_' displayorder="2">
          <title>Index</title>
          <ul>
            <li>
              <em>Dasein</em>
              , see
              <em>Eman</em>
              cipation, &#xEA;tre
            </li>
            <li>
              &#xE9;long&#xE9;,
              <xref target='_' pagenumber='true'>Clause 1</xref>
            </li>
            <li>
              <em>Eman</em>
              cipation,
              <xref target='_' pagenumber='true'>Clause 1</xref>
              ,
              <xref target='_' pagenumber='true'>1.1</xref>
              <ul>
                <li>
                  dans la France,
                  <xref target='_' pagenumber='true'>Clause 1</xref>
                  <ul>
                    <li>
                      &#xE0; Paris,
                      <xref target='_' pagenumber='true'>1.1</xref>
                    </li>
                    <li>
                      en Bretagne,
                      <xref target='_' pagenumber='true'>Clause 1</xref>
                    </li>
                  </ul>
                </li>
                <li>
                  dans les &#xC9;tats-Unis,
                  <xref target='_' pagenumber='true'>1.1</xref>
                </li>
              </ul>
            </li>
            <li>
              &#xEA;tre
              <ul>
                <li>
                  Husserl, see zebra, see also
                  <em>Eman</em>
                  cipation, zebra
                  <ul>
                    <li>
                      en allemand,
                      <xref target='_' pagenumber='true'>Clause 1</xref>
                    </li>
                  </ul>
                </li>
              </ul>
            </li>
            <li>
              zebra,
              <xref target='_' pagenumber='true'>1.1</xref>
            </li>
          </ul>
        </indexsect>
      </iso-standard>
    OUTPUT
    html = <<~OUTPUT
          <html lang='en'>
        <head/>
        <body lang='en'>
          <div class='title-section'>
            <p>&#160;</p>
          </div>
          <br/>
          <div class='prefatory-section'>
            <p>&#160;</p>
          </div>
          <br/>
          <div class='main-section'>
            <p class='zzSTDTitle1'/>
            <div id='A'>
              <h1>1</h1>
              <a id='_'/>
              <a id='_'/>
              <a id='_'/>
              <a id='_'/>
              <a id='_'/>
              <div id='B'>
                <span class='zzMoveToFollowing'>
                  <b>1.1&#160; </b>
                </span>
                <a id='_'/>
                <a id='_'/>
                <a id='_'/>
                <a id='_'/>
              </div>
            </div>
            <div id='_'>
              <h1>Index</h1>
              <ul>
                <li>
                  <i>Dasein</i>
                   , see
                  <i>Eman</i>
                   cipation, &#234;tre
                </li>
                <li>
                   &#233;long&#233;,
                  <a href='#_'>Clause 1</a>
                </li>
                <li>
                  <i>Eman</i>
                   cipation,
                  <a href='#_'>Clause 1</a>
                   ,
                  <a href='#_'>1.1</a>
                  <ul>
                    <li>
                       dans la France,
                      <a href='#_'>Clause 1</a>
                      <ul>
                        <li>
                           &#224; Paris,
                          <a href='#_'>1.1</a>
                        </li>
                        <li>
                           en Bretagne,
                          <a href='#_'>Clause 1</a>
                        </li>
                      </ul>
                    </li>
                    <li>
                       dans les &#201;tats-Unis,
                      <a href='#_'>1.1</a>
                    </li>
                  </ul>
                </li>
                <li>
                   &#234;tre
                  <ul>
                    <li>
                       Husserl, see zebra, see also
                      <i>Eman</i>
                       cipation, zebra
                      <ul>
                        <li>
                           en allemand,
                          <a href='#_'>Clause 1</a>
                        </li>
                      </ul>
                    </li>
                  </ul>
                </li>
                <li>
                   zebra,
                  <a href='#_'>1.1</a>
                </li>
              </ul>
            </div>
          </div>
        </body>
      </html>
    OUTPUT
    expect(xmlpp(strip_guid(IsoDoc::Iso::PresentationXMLConvert.new({})
      .convert("test", input, true)
      .gsub(%r{<localized-strings>.*</localized-strings>}m, ""))))
      .to be_equivalent_to xmlpp(presxml)
    expect(xmlpp(IsoDoc::Iso::HtmlConvert.new({})
      .convert("test", presxml, true))).to be_equivalent_to xmlpp(html)
  end
end
