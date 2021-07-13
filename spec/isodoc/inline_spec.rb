require "spec_helper"

RSpec.describe IsoDoc do
  it "processes inline formatting" do
    output = IsoDoc::Iso::HtmlConvert.new({}).convert("test", <<~"INPUT", true)
      <iso-standard xmlns="http://riboseinc.com/isoxml">
        <preface>
          <foreword>
            <p>
              <em>A</em>
              <strong>B</strong>
              <sup>C</sup>
              <sub>D</sub>
              <tt>E</tt>
              <strike>F</strike>
              <smallcap>G</smallcap>
              <br/>
              <hr/>
              <bookmark id="H"/>
              <pagebreak/>
            </p>
          </foreword>
        </preface>
        <sections>
      </iso-standard>
    INPUT
    expect(xmlpp(output)).to be_equivalent_to xmlpp(<<~"OUTPUT")
      #{HTML_HDR}
            <br/>
            <div>
              <h1 class="ForewordTitle">Foreword</h1>
              <p>
                <i>A</i>
                <b>B</b>
                <sup>C</sup>
                <sub>D</sub>
                <tt>E</tt>
                <s>F</s>
                <span style="font-variant:small-caps;">G</span>
                <br/>
                <hr/>
                <a id="H"/>
                <br/>
              </p>
            </div>
            <p class="zzSTDTitle1"/>
          </div>
        </body>
      </html>
    OUTPUT
  end

  it "processes links" do
    output = IsoDoc::Iso::HtmlConvert.new({}).convert("test", <<~"INPUT", true)
      <iso-standard xmlns="http://riboseinc.com/isoxml">
        <preface>
          <foreword>
            <p>
              <link target="http://example.com"/>
              <link target="http://example.com">example</link>
              <link target="mailto:fred@example.com"/>
              <link target="mailto:fred@example.com">mailto:fred@example.com</link>
            </p>
          </foreword>
        </preface>
        <sections>
      </iso-standard>
    INPUT
    expect(xmlpp(output)).to be_equivalent_to xmlpp(<<~"OUTPUT")
      #{HTML_HDR}
            <br/>
            <div>
              <h1 class="ForewordTitle">Foreword</h1>
              <p>
                <a href="http://example.com">http://example.com</a>
                <a href="http://example.com">example</a>
                <a href="mailto:fred@example.com">fred@example.com</a>
                <a href="mailto:fred@example.com">mailto:fred@example.com</a>
              </p>
            </div>
            <p class="zzSTDTitle1"/>
          </div>
        </body>
      </html>
    OUTPUT
  end

  it "processes unrecognised markup" do
    output = IsoDoc::Iso::HtmlConvert.new({}).convert("test", <<~"INPUT", true)
      <iso-standard xmlns="http://riboseinc.com/isoxml">
        <preface>
          <foreword>
            <p>
              <barry fred="http://example.com">example</barry>
            </p>
          </foreword>
        </preface>
        <sections>
      </iso-standard>
    INPUT
    expect(xmlpp(output)).to be_equivalent_to xmlpp(<<~"OUTPUT")
      #{HTML_HDR}
            <br/>
            <div>
              <h1 class="ForewordTitle">Foreword</h1>
              <p>
                <para>
                  <b role="strong">&lt;barry fred=&quot;http://example.com&quot;&gt;example&lt;/barry&gt;</b>
                </para>
              </p>
            </div>
            <p class="zzSTDTitle1"/>
          </div>
        </body>
      </html>
    OUTPUT
  end

  it "processes AsciiMath and MathML" do
    output = IsoDoc::Iso::HtmlConvert.new({}).convert("test", <<~"INPUT", true)
      <iso-standard xmlns="http://riboseinc.com/isoxml">
        <preface>
          <foreword>
            <p>
              <stem type="AsciiMath">A</stem>
              <stem type="MathML"><m:math><m:row>X</m:row></m:math></stem>
              <stem type="None">Latex?</stem>
            </p>
          </foreword>
        </preface>
        <sections>
      </iso-standard>
    INPUT
    expect(xmlpp(output.sub(/<html/, "<html xmlns:m='m'"))).to be_equivalent_to xmlpp(<<~"OUTPUT")
      #{HTML_HDR.sub(/<html/, "<html xmlns:m='m'")}
            <br/>
            <div>
              <h1 class="ForewordTitle">Foreword</h1>
              <p>
                <span class="stem">(#(A)#)</span>
                <span class="stem">
                  <m:math>
                    <m:row>X</m:row>
                  </m:math>
                </span>
                <span class="stem">Latex?</span>
              </p>
            </div>
            <p class="zzSTDTitle1"/>
          </div>
        </body>
      </html>
    OUTPUT
  end

  it "overrides AsciiMath delimiters" do
    output = IsoDoc::Iso::HtmlConvert.new({}).convert("test", <<~"INPUT", true)
      <iso-standard xmlns="http://riboseinc.com/isoxml">
        <preface>
          <foreword>
            <p><stem type="AsciiMath">A</stem>(#((Hello))#)</p>
          </foreword>
        </preface>
        <sections>
      </iso-standard>
    INPUT
    expect(xmlpp(output)).to be_equivalent_to xmlpp(<<~"OUTPUT")
      #{HTML_HDR}
              <br/>
              <div>
                <h1 class="ForewordTitle">Foreword</h1>
              <p>
                <span class="stem">(#(((A)#)))</span>
                (#((Hello))#)
              </p>
            </div>
            <p class="zzSTDTitle1"/>
          </div>
        </body>
      </html>
    OUTPUT
  end

  it "processes eref types" do
    output = IsoDoc::Iso::HtmlConvert.new({}).convert("test", <<~"INPUT", true)
      <iso-standard xmlns="http://riboseinc.com/isoxml">
        <preface>
          <foreword>
            <p>
              <eref type="footnote" bibitemid="ISO712" citeas="ISO 712">A</stem>
              <eref type="inline" bibitemid="ISO712" citeas="ISO 712">A</stem>
            </p>
          </foreword>
        </preface>
        <bibliography>
          <references id="_normative_references" normative="true" obligation="informative">
            <title>1<tab/>
              Normative references</title>
            <bibitem id="ISO712" type="standard">
              <title format="text/plain">Cereals and cereal products</title>
              <docidentifier>ISO 712</docidentifier>
              <contributor>
                <role type="publisher"/>
                <organization>
                  <abbreviation>ISO</abbreviation>
                </organization>
              </contributor>
            </bibitem>
          </references>
        </bibliography>
      </iso-standard>
    INPUT
    expect(xmlpp(output)).to be_equivalent_to xmlpp(<<~"OUTPUT")
      #{HTML_HDR}
            <br/>
            <div>
              <h1 class="ForewordTitle">Foreword</h1>
              <p>
                <sup><a href="#ISO712">A</a></sup>
                <a href="#ISO712">A</a>
              </p>
            </div>
            <p class="zzSTDTitle1"/>
            <div>
              <h1>1&#160; Normative references</h1>
              <p id="ISO712" class="NormRef">ISO 712, <i>Cereals and cereal products</i></p>
            </div>
          </div>
        </body>
      </html>
    OUTPUT
  end

  it "processes eref content" do
    output = IsoDoc::Iso::PresentationXMLConvert.new({}).convert("test", <<~"INPUT", true)
      <iso-standard xmlns="http://riboseinc.com/isoxml">
        <preface>
          <foreword>
            <p>
              <eref bibitemid="IEV" citeas="IEV" type="inline">
                <locality type="clause">
                  <referenceFrom>1-2-3</referenceFrom>
                </locality>
              </eref>
              <eref bibitemid="ISO712" citeas="ISO 712" type="inline"/>
              <eref bibitemid="ISO712" type="inline"/>
              <eref bibitemid="ISO712" type="inline">
                <locality type="table">
                  <referenceFrom>1</referenceFrom>
                </locality>
              </eref>
              <eref bibitemid="ISO712" type="inline">
                <locality type="table">
                  <referenceFrom>1</referenceFrom>
                  <referenceTo>1</referenceTo>
                </locality>
              </eref>
              <eref bibitemid="ISO712" type="inline">
                <locality type="clause">
                  <referenceFrom>1</referenceFrom>
                </locality>
                <locality type="table">
                  <referenceFrom>1</referenceFrom>
                </locality>
              </eref>
              <eref bibitemid="ISO712" type="inline">
                <locality type="clause">
                  <referenceFrom>1</referenceFrom>
                </locality>
                <locality type="list">
                  <referenceFrom>a</referenceFrom>
                </locality>
              </eref>
              <eref bibitemid="ISO712" type="inline">
                <locality type="clause">
                  <referenceFrom>1</referenceFrom>
                </locality>
              </eref>
              <eref bibitemid="ISO712" type="inline">
                <locality type="clause">
                  <referenceFrom>1.5</referenceFrom>
                </locality>
              </eref>
              <eref bibitemid="ISO712" type="inline">
                <locality type="table">
                  <referenceFrom>1</referenceFrom>
                </locality>A</eref>
              <eref bibitemid="ISO712" type="inline">
                <locality type="whole"/>
              </eref>
              <eref bibitemid="ISO712" type="inline">
                <locality type="locality:prelude">
                  <referenceFrom>7</referenceFrom>
                </locality>
              </eref>
              <eref bibitemid="ISO712" citeas="ISO 712" type="inline">A</eref>
            </p>
          </foreword>
        </preface>
        <bibliography>
          <references id="_normative_references" normative="true" obligation="informative">
            <title>Normative References</title>
            <bibitem id="ISO712" type="standard">
              <title format="text/plain">Cereals and cereal products</title>
              <docidentifier>ISO 712</docidentifier>
              <contributor>
                <role type="publisher"/>
                <organization>
                  <abbreviation>ISO</abbreviation>
                </organization>
              </contributor>
            </bibitem>
          </references>
        </bibliography>
      </iso-standard>
    INPUT
    expect(xmlpp(output).sub(%r{<i18nyaml>.*</i18nyaml>}m, "")).to be_equivalent_to xmlpp(<<~"OUTPUT")
      <?xml version='1.0'?>
      <iso-standard type="presentation" xmlns="http://riboseinc.com/isoxml">
        <preface>
          <foreword displayorder="1">
            <p>
              <eref bibitemid="IEV" citeas="IEV" type="inline">
                <locality type="clause">
                  <referenceFrom>1-2-3</referenceFrom>
                </locality>IEV, 1-2-3</eref>
              <eref bibitemid="ISO712" citeas="ISO 712" type="inline">ISO 712</eref>
              <eref bibitemid="ISO712" type="inline">ISO 712</eref>
              <eref bibitemid="ISO712" type="inline">
                <locality type="table">
                  <referenceFrom>1</referenceFrom>
                </locality>ISO 712, Table 1</eref>
              <eref bibitemid="ISO712" type="inline">
                <locality type="table">
                  <referenceFrom>1</referenceFrom>
                  <referenceTo>1</referenceTo>
                </locality>ISO 712, Table 1–1</eref>
              <eref bibitemid="ISO712" type="inline">
                <locality type="clause">
                  <referenceFrom>1</referenceFrom>
                </locality>
                <locality type="table">
                  <referenceFrom>1</referenceFrom>
                </locality>ISO 712, Clause 1, Table 1</eref>
              <eref bibitemid="ISO712" type="inline">
                <locality type="clause">
                  <referenceFrom>1</referenceFrom>
                </locality>
                <locality type="list">
                  <referenceFrom>a</referenceFrom>
                </locality>ISO 712, Clause 1 a)</eref>
              <eref bibitemid="ISO712" type="inline">
                <locality type="clause">
                  <referenceFrom>1</referenceFrom>
                </locality>ISO 712, Clause 1</eref>
              <eref bibitemid="ISO712" type="inline">
                <locality type="clause">
                  <referenceFrom>1.5</referenceFrom>
                </locality>ISO 712, 1.5</eref>
              <eref bibitemid="ISO712" type="inline">
                <locality type="table">
                  <referenceFrom>1</referenceFrom>
                </locality>A</eref>
              <eref bibitemid="ISO712" type="inline">
                <locality type="whole"/>ISO 712, Whole of text</eref>
              <eref bibitemid="ISO712" type="inline">
                <locality type="locality:prelude">
                  <referenceFrom>7</referenceFrom>
                </locality>ISO 712, Prelude 7</eref>
              <eref bibitemid="ISO712" citeas="ISO 712" type="inline">A</eref>
            </p>
          </foreword>
        </preface>
        <bibliography>
          <references id="_normative_references" normative="true" obligation="informative" displayorder="2">
            <title depth="1">1<tab/>
              Normative References</title>
            <bibitem id="ISO712" type="standard">
              <title format="text/plain">Cereals and cereal products</title>
              <docidentifier>ISO 712</docidentifier>
              <contributor>
                <role type="publisher"/>
                <organization>
                  <abbreviation>ISO</abbreviation>
                </organization>
              </contributor>
            </bibitem>
          </references>
        </bibliography>
      </iso-standard>
    OUTPUT
  end

  it "processes concept markup" do
    input = <<~INPUT
          <iso-standard xmlns="http://riboseinc.com/isoxml">
          <sections>
          <terms id="Terms">
          <p>
          <ul>
                    <li><concept><refterm>term0</refterm>
              <xref target='clause1'/>
            </concept></li>
            <li><concept><refterm>term1</refterm>
              <renderterm>term</renderterm>
              <xref target='clause1'/>
            </concept></li>
          <li><concept><refterm>term2</refterm>
              <renderterm>w[o]rd</renderterm>
              <xref target='clause1'>Clause #1</xref>
            </concept></li>
            <li><concept><refterm>term3</refterm>
              <renderterm>term</renderterm>
              <eref bibitemid="ISO712" type="inline" citeas="ISO 712"/>
            </concept></li>
            <li><concept><refterm>term4</refterm>
              <renderterm>word</renderterm>
              <eref bibitemid="ISO712" type="inline" citeas="ISO 712">The Aforementioned Citation</eref>
            </concept></li>
            <li><concept><refterm>term5</refterm>
              <renderterm>word</renderterm>
              <eref bibitemid="ISO712" type="inline" citeas="ISO 712">
                <locality type='clause'>
                  <referenceFrom>3.1</referenceFrom>
                </locality>
                <locality type='figure'>
                  <referenceFrom>a</referenceFrom>
                </locality>
              </eref>
            </concept></li>
            <li><concept><refterm>term6</refterm>
              <renderterm>word</renderterm>
              <eref bibitemid="ISO712" type="inline" citeas="ISO 712">
              <localityStack>
                <locality type='clause'>
                  <referenceFrom>3.1</referenceFrom>
                </locality>
              </localityStack>
              <localityStack>
                <locality type='figure'>
                  <referenceFrom>b</referenceFrom>
                </locality>
              </localityStack>
              </eref>
            </concept></li>
            <li><concept><refterm>term7</refterm>
              <renderterm>word</renderterm>
              <eref bibitemid="ISO712" type="inline" citeas="ISO 712">
              <localityStack>
                <locality type='clause'>
                  <referenceFrom>3.1</referenceFrom>
                </locality>
              </localityStack>
              <localityStack>
                <locality type='figure'>
                  <referenceFrom>b</referenceFrom>
                </locality>
              </localityStack>
              The Aforementioned Citation
              </eref>
            </concept></li>
            <li><concept><refterm>term8</refterm>
              <renderterm>word</renderterm>
              <termref base='IEV' target='135-13-13'/>
            </concept></li>
            <li><concept><refterm>term9</refterm>
              <renderterm>word</renderterm>
              <termref base='IEV' target='135-13-13'>The IEV database</termref>
            </concept></li>
            <li><concept><refterm>term10</refterm>
              <renderterm>word</renderterm>
              <strong>error!</strong>
            </concept></li>
            </ul>
          </p>
          </terms>
          <clause id="clause1"><title>Clause 1</title></clause>
          </sections>
          <bibliography><references id="_normative_references" obligation="informative" normative="true"><title>Normative References</title>
          <p>The following documents are referred to in the text in such a way that some or all of their content constitutes requirements of this document. For dated references, only the edition cited applies. For undated references, the latest edition of the referenced document (including any amendments) applies.</p>
      <bibitem id="ISO712" type="standard">
        <title format="text/plain">Cereals or cereal products</title>
        <title type="main" format="text/plain">Cereals and cereal products</title>
        <docidentifier type="ISO">ISO 712</docidentifier>
        <contributor>
          <role type="publisher"/>
          <organization>
            <name>International Organization for Standardization</name>
          </organization>
        </contributor>
      </bibitem>
      </references></bibliography>
          </iso-standard>
    INPUT
    presxml = <<~OUTPUT
          <iso-standard xmlns="http://riboseinc.com/isoxml" type="presentation">
          <sections>
          <terms id="Terms" displayorder="2"><title>2</title>
          <p>
          <ul>
                    <li>
              (<xref target="clause1">Clause 3</xref>)
            </li>
            <li>
              <em>term</em>
              (<xref target="clause1">Clause 3</xref>)
            </li>
          <li>
              <em>w[o]rd</em>
              (<xref target="clause1">Clause #1</xref>)
            </li>
            <li>
              <em>term</em>
              (<eref bibitemid="ISO712" type="inline" citeas="ISO 712">ISO 712</eref>)
            </li>
            <li>
              <em>word</em>
              (<eref bibitemid="ISO712" type="inline" citeas="ISO 712">The Aforementioned Citation</eref>)
            </li>
            <li>
              <em>word</em>
              (<eref bibitemid="ISO712" type="inline" citeas="ISO 712"><locality type="clause">
                  <referenceFrom>3.1</referenceFrom>
                </locality><locality type="figure">
                  <referenceFrom>a</referenceFrom>
                </locality>ISO 712, 3.1, Figure a</eref>)
            </li>
            <li>
              <em>word</em>
              (<eref bibitemid="ISO712" type="inline" citeas="ISO 712"><localityStack>
                <locality type="clause">
                  <referenceFrom>3.1</referenceFrom>
                </locality>
              </localityStack><localityStack>
                <locality type="figure">
                  <referenceFrom>b</referenceFrom>
                </locality>
              </localityStack>ISO 712, 3.1; Figure b</eref>)
            </li>
            <li>
              <em>word</em>
              (<eref bibitemid="ISO712" type="inline" citeas="ISO 712">
              <localityStack>
                <locality type="clause">
                  <referenceFrom>3.1</referenceFrom>
                </locality>
              </localityStack>
              <localityStack>
                <locality type="figure">
                  <referenceFrom>b</referenceFrom>
                </locality>
              </localityStack>
              The Aforementioned Citation
              </eref>)
            </li>
            <li>
              <em>word</em>
              [term defined in <termref base="IEV" target="135-13-13"/>]
            </li>
            <li>
              <em>word</em>
              [term defined in <termref base="IEV" target="135-13-13">The IEV database</termref>]
            </li>
            <li>
              <em>word</em>
              <strong>error!</strong>
            </li>
            </ul>
          </p>
          </terms>
          <clause id="clause1" displayorder="3"><title depth="1">3<tab/>Clause 1</title></clause>
          </sections>
          <bibliography><references id="_normative_references" obligation="informative" normative="true" displayorder="1"><title depth="1">1<tab/>Normative References</title>
          <p>The following documents are referred to in the text in such a way that some or all of their content constitutes requirements of this document. For dated references, only the edition cited applies. For undated references, the latest edition of the referenced document (including any amendments) applies.</p>
      <bibitem id="ISO712" type="standard">
        <title format="text/plain">Cereals or cereal products</title>
        <title type="main" format="text/plain">Cereals and cereal products</title>
        <docidentifier type="ISO">ISO 712</docidentifier>
        <contributor>
          <role type="publisher"/>
          <organization>
            <name>International Organization for Standardization</name>
          </organization>
        </contributor>
      </bibitem>
      </references></bibliography>
          </iso-standard>
    OUTPUT
    output = <<~OUTPUT
      #{HTML_HDR}
             <p class='zzSTDTitle1'/>
             <div>
               <h1>1&#160; Normative References</h1>
               <p>
                 The following documents are referred to in the text in such a way that
                 some or all of their content constitutes requirements of this
                 document. For dated references, only the edition cited applies. For
                 undated references, the latest edition of the referenced document
                 (including any amendments) applies.
               </p>
               <p id='ISO712' class='NormRef'>
                 ISO 712,
                 <i>Cereals and cereal products</i>
               </p>
             </div>
             <div id='Terms'>
               <h1>2</h1>
               <p>
                 <ul>
                   <li>
                      (
                     <a href='#clause1'>Clause 3</a>
                     )
                   </li>
                   <li>
                     <i>term</i>
                      (
                     <a href='#clause1'>Clause 3</a>
                     )
                   </li>
                   <li>
                     <i>w[o]rd</i>
                      (
                     <a href='#clause1'>Clause #1</a>
                     )
                   </li>
                   <li>
                     <i>term</i>
                      (
                     <a href='#ISO712'>ISO 712</a>
                     )
                   </li>
                   <li>
                     <i>word</i>
                      (
                     <a href='#ISO712'>The Aforementioned Citation</a>
                     )
                   </li>
                   <li>
                     <i>word</i>
                      (
                     <a href='#ISO712'>ISO 712, 3.1, Figure a</a>
                     )
                   </li>
                   <li>
                     <i>word</i>
                      (
                     <a href='#ISO712'>ISO 712, 3.1; Figure b</a>
                     )
                   </li>
                   <li>
                     <i>word</i>
                      (
                     <a href='#ISO712'> The Aforementioned Citation </a>
                     )
                   </li>
                   <li>
                     <i>word</i>
                      [term defined in Termbase IEV, term ID 135-13-13]
                   </li>
                   <li>
                     <i>word</i>
                      [term defined in The IEV database]
                   </li>
                   <li>
                     <i>word</i>
                     <b>error!</b>
                   </li>
                 </ul>
               </p>
             </div>
             <div id='clause1'>
               <h1>3&#160; Clause 1</h1>
             </div>
           </div>
         </body>
       </html>
    OUTPUT
    expect(xmlpp(IsoDoc::Iso::PresentationXMLConvert.new({})
      .convert("test", input, true))).to be_equivalent_to xmlpp(presxml)
    expect(xmlpp(IsoDoc::Iso::HtmlConvert.new({})
      .convert("test", presxml, true))).to be_equivalent_to xmlpp(output)
  end

  it "processes concept markup by context" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
      <preface><foreword id="A">
      <ul>
      <li><concept><refterm>term1</refterm>
          <renderterm>term</renderterm>
          <xref target='clause1'/>
        </concept></li>
        </ul>
      </foreword></preface>
      <sections>
      <terms id="Terms">
      <term id="clause1">
       <ul>
      <li><concept><refterm>term1</refterm>
          <renderterm>term</renderterm>
          <xref target='clause1'/>
        </concept></li>
      <li><concept><refterm>term1</refterm>
          <renderterm>term</renderterm>
          <xref target='clause1'/>
        </concept></li>
        </ul>
        </term>
      </terms>
      </sections>
      </iso-standard>
    INPUT
    presxml = <<~OUTPUT
          <iso-standard xmlns='http://riboseinc.com/isoxml' type='presentation'>
        <preface>
          <foreword id='A' displayorder='1'>
            <ul>
              <li>term</li>
            </ul>
          </foreword>
        </preface>
        <sections>
          <terms id='Terms' displayorder='2'>
            <title>1</title>
            <term id='clause1'>
              <name>1.1</name>
              <ul>
                <li>
                  <em>term</em>
                   (
                  <xref target='clause1'>1.1</xref>
                  )
                </li>
                <li>term</li>
              </ul>
            </term>
          </terms>
        </sections>
      </iso-standard>
    OUTPUT
    expect(xmlpp(IsoDoc::Iso::PresentationXMLConvert.new({})
       .convert("test", input, true))).to be_equivalent_to xmlpp(presxml)
  end
 
  it "processes concept attributes" do
    input = <<~INPUT
       <iso-standard xmlns="http://riboseinc.com/isoxml">
       <sections>
       <clause id="clause1"><title>Clause 1</title></clause>
       <terms id="A">
       <p>
       <ul>
       <li>
              <concept ital="true"><refterm>term</refterm>
           <renderterm>term</renderterm>
           <xref target='clause1'/>
         </concept></li>
         <li><concept ref="true"><refterm>term</refterm>
           <renderterm>term</renderterm>
           <xref target='clause1'/>
         </concept></li>
       <li><concept ital="true" ref="true"><refterm>term</refterm>
           <renderterm>term</renderterm>
           <xref target='clause1'/>
         </concept></li>
        <li><concept ital="false"><refterm>term</refterm>
           <renderterm>term</renderterm>
           <xref target='clause1'/>
         </concept></li>
         <li><concept ref="false"><refterm>term</refterm>
           <renderterm>term</renderterm>
           <xref target='clause1'/>
         </concept></li>
       <li><concept ital="false" ref="false"><refterm>term</refterm>
           <renderterm>term</renderterm>
           <xref target='clause1'/>
         </concept></li>
        </ul></p>
       </terms>
       </sections>
      </iso-standard>
    INPUT
    presxml = <<~OUTPUT
           <iso-standard xmlns="http://riboseinc.com/isoxml" type="presentation">
        <sections>
        <clause id="clause1" displayorder="1"><title depth="1">1<tab/>Clause 1</title></clause>
        <terms id="A" displayorder="2"><title>2</title>
        <p>
        <ul>
        <li>

            <em>term</em>
            (<xref target="clause1">Clause 1</xref>)
          </li>
          <li>
            term
            (<xref target="clause1">Clause 1</xref>)
          </li>
        <li>
            <em>term</em>
            (<xref target="clause1">Clause 1</xref>)
          </li>
         <li>
            term

          </li>
          <li>
            term

          </li>
        <li>
            term

          </li>
         </ul></p>
        </terms>
        </sections>
       </iso-standard>
    OUTPUT
    output = <<~OUTPUT
    #{HTML_HDR}
       <p class='zzSTDTitle1'/>
       <div id='clause1'>
         <h1>1&#160; Clause 1</h1>
       </div>
       <div id='A'>
         <h1>2</h1>
         <p>
                          <ul>
                   <li>
                     <i>term</i>
                      (
                     <a href='#clause1'>Clause 1</a>
                     )
                   </li>
                   <li>
                      term (
                     <a href='#clause1'>Clause 1</a>
                     )
                   </li>
                   <li>
                     <i>term</i>
                      (
                     <a href='#clause1'>Clause 1</a>
                     )
                   </li>
                   <li> term </li>
                   <li> term </li>
                   <li> term </li>
                 </ul>
         </p>
       </div>
     </div>
   </body>
 </html>
    OUTPUT
    expect(xmlpp(IsoDoc::Iso::PresentationXMLConvert.new({})
      .convert("test", input, true))).to be_equivalent_to xmlpp(presxml)
    expect(xmlpp(IsoDoc::Iso::HtmlConvert.new({})
      .convert("test", presxml, true))).to be_equivalent_to xmlpp(output)
  end
end
