<HTML xmlns="http://www.w3.org/1999/xhtml">
 <!-- #BeginTemplate "/Templates/index.dwt" -->
 <HEAD>
  <!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3c.org/TR/1999/REC-html401-19991224/loose.dtd">
  <!-- saved from url=(0046)http://forest.moscowfsl.wsu.edu/BAERTOOLS/VAR/ --><!-- #BeginTemplate "/Templates/home_deh.dwt" --><HEAD>
  <!-- #BeginEditable "doctitle" --> 
  <TITLE>RMRS - BAER Road Treatment Tools - Curve Number Methods</TITLE>
<!-- #EndEditable -->
  <!-- DW6 -->
  <!-- PAGE TITLE - NAMING CONFIGURATION SHOULD BE "RMRS - PAGE TITLE" -->
  <!-- #BeginEditable "doctitle" --><!-- #EndEditable -->
  <!-- LEAVE THIS ALONE BELOW -->
  <META http-equiv=Content-Type content="text/html; charset=utf-8">
  <META content="USFS Version 3.02AB, 05 February 2003" name=version><!-- LEAVE THIS ALONE ABOVE --><!-- EDITABLE META TAGS - IDEALLY THE DESCRIPTION AND KEYWORDS SHOULD ADDRESS THE CONTENT OF EACH INDIVIDUAL PAGE. --><!-- #BeginEditable "metatags" --> 
  <META content="David Hall" name=author>
  <META content="Suzy Stephens, RMRS" name=template_author>
  <META http-equiv=Reply-to content=dehall@>
  <META content="USDA Forest Service - Rocky Mountain Research Station, Moscow Forestry Sciences Laboratory" name=Description>
  <META content="Rocky Mountain Research Station, Forest Service,&#10;    BAER, Burned Area Emergency Response" name=Keywords>
<!-- #EndEditable -->
<!-- CSS LINKS - IF YOU WISH TO USE YOUR OWN CSS MAKE SURE THEY GO ABOVE THIS COMMENT. -->
   <link rel="stylesheet" type="text/css" media="screen" href="/local_resources/styles/nn4.css" />
   <link rel="stylesheet" type="text/css" media="print" href="/local_resources/styles/print.css" />

   <style type="text/css" media="screen">
    @import url(/local_resources/styles/screen.css);.style1 {color: #FFFFFF}
   </style>
  <!-- JAVASCRIPT LINK  -->
   <script type="text/javascript" src="/local_resources/scripts/script.js"></script>

    <!-- TEMPORARY STYLE FOR TROUBLESHOOTING
     <style type="text/css" media="screen">
      td {border: 1px solid #FF0000;}
      table {border: 2px solid #66CCFF;}
     </style>
     -->
 </head>
 <body>
  <TABLE cellSpacing=0 cellPadding=0 width="100%" summary="Layout table: Main table. The first row contains a USDAFS link and a service wide drop-down navigation.  The second row and third rows contains the Station name and search engine.  Below this are two cells.  The left cell contains the site navigation.  The right cell contains the content of the page." border=0>
<!-- ROW 1.0 - GLOBAL NAVIGATION TABLE START
     TABINDEX: 1-4
     ROW CONTAINS:
      THE HIDDEN LINK TO THE CONTENT OF THIS PAGE
      THE USDA LOGO AND LINK TO WO SITE
      DROPDOWN MENU
     -->
  <TBODY>
   <TR>
    <TD id=glob-nav-left width=229 colSpan=2>
     <A id=top name=top></A>
     <A class=hidden tabIndex=1 href="http://forest.moscowfsl.wsu.edu/BAERTOOLS/VAR/#content">[Jump to the main content of this page]</A>
     <BR>
     <A tabIndex=2 href="http://www.fs.fed.us/">
      <IMG height=29 alt="USDA Forest Service" src="/local_resources/images/logos/usda-fs-text.gif" width=143 border=0></A>
     </TD>
    <TD id=glob-nav-right align=right width="100%">
      <FORM title="[Form]: Drop-down navigation for the USDA Forest Service." 
      action=http://www.fs.fed.us/cgi-bin/fsnavigator.cgi method=post><LABEL for=globalnav>&nbsp;</LABEL> 
      <DIV class=align-right><SELECT id=globalnav tabIndex=3 name=fsnavigator> 
        <OPTION value=# selected>Forest Service National Links</OPTION>
        <OPTION value=http://www.fs.fed.us>Forest Service Home</OPTION>
        <OPTION value=http://www.fs.fed.us/fsjobs/forestservice/index.html>Employment</OPTION> 
        <OPTION value=http://www.fs.fed.us/fire/>Fire and Aviation</OPTION> 
        <OPTION value=http://www.fs.fed.us/global/>International Forestry</OPTION>
        <OPTION value=http://www.fs.fed.us/kids/>Just for Kids</OPTION>
        <OPTION value=http://www.fs.fed.us/maps/>Maps and Brochures</OPTION>
        <OPTION value=http://www.fs.fed.us/passespermits/>Passes and Permits</OPTION> 
        <OPTION value=http://www.fs.fed.us/photovideo/>Photo and Video Gallery</OPTION>
        <OPTION value=http://www.fs.fed.us/publications/>Publications</OPTION>
        <OPTION value=http://www.fs.fed.us/recreation/>Recreational Activities</OPTION> 
        <OPTION value=http://www.fs.fed.us/research/>Research and Development</OPTION>
        <OPTION value=http://www.fs.fed.us/spf/>State and Private Forestry</OPTION>
       </SELECT> &nbsp;
       <INPUT class=button tabIndex=4 type=submit value=Go! name=button> 
      </DIV>
     </FORM>
    </TD>
   </TR>
<!-- ROW 1.0 - GLOBAL NAVIGATION TABLE STOP -->
<!-- ROW 2.0 - LOCAL HEADER START  
	TAB INDEX: NONE
	ROW CONTAINS:
 	  2 GREEN ON GREEN TREE IMAGES (LEFT CELLS)
	  STATION NAME (RIGHT CELL) -->
   <TR id=header-tr>
    <TD id=header-left width=189>
     <IMG height=44 alt="" src="/local_resources/images/slices/trees-left.gif" width=189>
    </TD>
    <TD id=header-center width=40>
     <IMG height=44 alt="" src="/local_resources/images/slices/trees-right.gif" width=40>
    </TD>
    <TD id=header-right>
      <H3>
       <IMG height=40 alt="" src="/local_resources/images/rmrs/rmrs_index_top.gif" width=75 align=right>
       <SPAN class=style1>Burned Area Emergency Response Tools</SPAN>
      </H3>
     </TD>
    </TR>
  <!-- ROW 2.0 - HEADER TABLE STOP  -->
  <!-- ROW 3.0 - SEARCH AND ARCH TABLE START  -->
  <!-- TAB INDEX: 5-6 -->
  <!-- ROW CONTAINS:
	 	SEARCH ENGINE
	 	1/4 ARCH IMAGE -->
   <TR>
    <TD id=search-table-left-cell width=189><IMG height=14 alt="" 
      src="/local_resources/images/slices/search-head.gif" width=189> 
      <FORM id=search_form title="[Form]: Google search of Moscow FSL site." 
      action=http://www.google.com/search method=get>
      <DIV><INPUT type=hidden value=forest.moscowfsl.wsu.edu name=as_sitesearch> 
      <LABEL for=search_field>&nbsp;</LABEL>
      <INPUT id=search_field 
      title="Enter a keyword or phrase you wish to search for.  Click the 'Search' button to conduct the search." 
      onclick="value=''" tabIndex=5 size=12 value="(enter query)" 
      name=as_q>&nbsp; <INPUT class=button tabIndex=6 type=submit value=Search> 
      </DIV>
     </FORM>
    </TD>
    <TD id=search-table-right-cell width="100%" colSpan=2><IMG height=31 
      alt="" src="/local_resources/images/slices/arch-basic.gif" width=322>
     </TD>
    </TR>
  <!-- ROW 3.0 - SEARCH AND ARCH TABLE STOP  -->
  <!-- ROW 4.0A - MAIN CONTENT AND NAVIGATION START 
	TAB INDEX: 7-20 (only main navigation areas) 
	INCLUDES:
		MAIN NAVIGATION CELL WITH THREE NESTED TABLES
			1. PRIMARY NAVIGATION TABLE
			2. SECONDARY NAVIGATION TABLE
			3. STATION NAME AND ADDRESS INFORMATION PLUS USDA AND FS LOGOS
		MAIN CONTENT CELL WITH CONTENT ANCHOR -->
    <TR>
  <!-- MAIN NAVIGATION CELL WITH TWO NESTED TABLES START -->
     <TD id=main-table-left-cell vAlign=top width=189>
  <!-- PRIMARY NAVIGATION TABLE START - TABLE 4.1 -->
  <!-- #BeginLibraryItem "/Library/nav1-home-index.lbi" -->
      <TABLE id=prim-nav-table cellSpacing=0 cellPadding=0 width="100%" 
      summary="Layout table: Main Navigation.  The column on the left contains image bullets.  The column on the right contains links." border=0>
  <!-- RMRS HOME LINK -->
       <TBODY>
        <TR bgColor=#ded794>
         <TD width=21><IMG height=16 alt="" src="/local_resources/images/bullets/active-link.gif" width=21></TD>
         <TD width=168><A class=main-nav-current tabIndex=8 href="http://forest.moscowfsl.wsu.edu/">Moscow FSL Home Page</A></TD>
        </TR><!-- AT THE LAB -->
        <TR class=p-link-not-active-tr>
         <TD><IMG height=16 alt="" src="/local_resources/images/bullets/not-active-link.gif" width=21></TD>
         <TD><A class=main-nav-not-current tabIndex=10 href="/atthelab.html">At the lab</A></TD>
        </TR><!-- ABOUT US LINK -->
  <!-- CONTACT US LINK -->
  <!-- PERSONNEL LINK -->
        <TR class=p-link-not-active-tr>
          <TD><IMG height=16 alt="" src="/local_resources/images/bullets/not-active-link.gif" width=21></TD>
          <TD><A class=main-nav-not-current tabIndex=11 href="/people/">Personnel</A></TD>
        </TR>
<!-- RESEARCH/STUDIES LINK -->
        <TR class=p-link-not-active-tr>
         <TD><IMG height=16 alt="" src="/local_resources/images/bullets/not-active-link.gif" width=21></TD>
         <TD><A class=main-nav-not-current tabIndex=12 href="/software.html">Modeling Software</A></TD>
        </TR>
<!-- PUBLICATIONS LINK -->
        <TR class=p-link-not-active-tr>
         <TD><IMG height=16 alt="" src="/local_resources/images/bullets/not-active-link.gif" width=21></TD>
          <TD><A class=main-nav-not-current tabIndex=14 href="/library/">Publications</A></TD>
        </TR>
<!-- EXPERIMENTAL FORESTS LINK -->
        <TR class=p-link-not-active-tr>
         <TD><IMG height=16 alt="" src="/local_resources/images/bullets/not-active-link.gif" width=21></TD>
         <TD><A class=main-nav-not-current tabIndex=16 href="/ef/">Experimental Forests</A></TD>
        </TR>
<!-- FAQ LINK -->
<!-- NEWS LINK -->
        <TR class=p-link-not-active-tr>
         <TD><IMG height=16 alt="" src="/local_resources/images/bullets/not-active-link.gif" width=21></TD>
         <TD><A class=main-nav-not-current tabIndex=18 href="/news.html">News</A></TD>
        </TR>
<!-- SITE MAP LINK -->
<!-- GREEN SPACER -->
        <TR>
         <TD colSpan=2>&nbsp;</TD>
        </TR>
       </TBODY>
      </TABLE>
<!-- #EndLibraryItem -->
<!-- TABLE 4.1 - PRIMARY NAVIGATION TABLE STOP -->
<!-- TABLE 4.2 - SECONDARY NAVIGATION TABLE START -->
      <DIV id=top-space>
<!-- #BeginLibraryItem "/Library/nav2-global-local-links.lbi" -->
      <TABLE id=sec-nav-table cellSpacing=0 cellPadding=0 width="100%" 
      summary="Layout table: Secondary Navigation. The column on the left contains bullet images.  The column on the right contains links." border=0>
       <TBODY>
        <TR>
         <TD colSpan=2 height=20><IMG height=10 alt="" src="/local_resources/images/bullets/local-link.gif" width=21></TD>
         <TD height=20><A class=main-nav-current href="http://www.fs.fed.us/rm/">Rocky Mountain Research Station</A></TD>
        </TR>
        <TR>
         <TD colSpan=2 height=20><IMG height=10 alt="" src="/local_resources/images/bullets/local-link.gif" width=21></TD>
         <TD height=20><A class=main-nav-current href="http://www.fs.fed.us/research/">Forest Service Research</A></TD>
        </TR>
        <TR>
         <TD colSpan=3 height=20>
          <HR>
         </TD>
        </TR>
        <TR>
         <TD colSpan=2 height=20><IMG height=16 alt="" src="/local_resources/images/bullets/local-link.gif" width=21></TD>
         <TD height=20><A class=main-nav-current href="/BAERTOOLS/ROADTRT/Peakflow/">Post-fire peak flow and erosion estimation</A> </TD>
        </TR>
        <TR>
         <TD width=10>&nbsp;</TD>
         <TD height=20><IMG height=10 alt="" src="/local_resources/images/bullets/local-link.gif" width=21></TD>
          <TD height=20><A class=main-nav-current href="/BAERTOOLS/ROADTRT/Peakflow/USGS/">USGS Regression</A></TD>
        </TR>
        <TR>
         <TD>&nbsp;</TD>
         <TD height=20><IMG height=10 alt="" src="/local_resources/images/bullets/local-link.gif" width=21></TD>
         <TD height=20><A class=main-nav-current href="/BAERTOOLS/ROADTRT/Peakflow/CN/">Curve Number</A></TD>
        </TR>
        <TR>
         <TD>&nbsp;</TD>
         <TD height=20><IMG height=10 alt="" src="/local_resources/images/bullets/local-link.gif" width=21></TD>
         <TD height=20><A class=main-nav-current href="/BAERTOOLS/ROADTRT/Peakflow/Rule_Thumb/">Rule of Thumb</A></TD>
        </TR>
        <TR>
         <TD width=10>&nbsp;</TD>
         <TD height=20><IMG height=10 alt="" src="/local_resources/images/bullets/local-link.gif" width=21></TD>
         <TD height=20><A class=main-nav-current href="/BAERTOOLS/ROADTRT/Peakflow/TR55/">TR-55</A></TD>
        </TR>
        <TR>
         <TD width=10>&nbsp;</TD>
         <TD height=20><IMG height=10 alt="" src="/local_resources/images/bullets/local-link.gif" width=21></TD>
         <TD height=20><A class=main-nav-current href="/BAERTOOLS/ROADTRT/Peakflow/ERMiT/">ERMiT</A></TD>
        </TR>
        <TR>
         <TD width=10>&nbsp;</TD>
         <TD height=20><IMG height=10 alt="" src="/local_resources/images/bullets/local-link.gif" width=21></TD>
         <TD height=20><A class=main-nav-current href="/BAERTOOLS/ROADTRT/Peakflow/FERGI/">FERGI</A></TD>
        </TR>
        <TR>
          <TD width=10>&nbsp;</TD>
          <TD height=20><IMG height=10 alt="" src="/local_resources/images/bullets/local-link.gif" width=21></TD>
          <TD height=20><A class=main-nav-current href="/BAERTOOLS/ROADTRT/Peakflow/WATBAL/">WATBAL</A></TD>
        </TR>
        <TR>
          <TD colSpan=2 height=20><IMG height=16 alt="" src="/local_resources/images/bullets/local-link.gif" width=21></TD>
          <TD height=20><A class=main-nav-current href="/BAERTOOLS/ROADTRT/Treatments/">BAER road treatments</A> </TD></TR>
        <TR>
         <TD colSpan=3 height=20>
          <HR>
         </TD>
        </TR>
        <TR>
         <TD>&nbsp;</TD>
         <TD height=20><IMG height=10 alt="" src="/local_resources/images/bullets/local-link.gif" width=21></TD>
         <TD height=20>
          <A class=main-nav-current href="http://www.srs.fs.usda.gov/customer/commentcard_rmrs.htm">Evaluate Our Service</A>
         </TD>
        </TR>
       </TBODY>
      </TABLE>
<!-- #EndLibraryItem -->
     </DIV>
<!-- TABLE 4.2  - SECONDARY NAVIGATION TABLE STOP -->
<!-- TABLE 4.3 STATION ADRESS TABLE START -->
<!-- #BeginLibraryItem "/Library/nav2-global-local-address.lbi" -->
      <TABLE id=address-table cellSpacing=0 cellPadding=0 width="100%" 
       summary="Layout table: Address.  The top cell contains the Station address. The bottom cell contains the USDA and USFS logos." 
      border=0>
        <TBODY>
        <TR>
         <TD class=ten-px-pad>
          <P>
           <FONT size=1>
            <STRONG>Moscow Forestry Sciences Laboratory</STRONG><BR>
            1221 South Main Street<BR>
            Moscow, ID 
            83843<BR>
           (208) 882-3557<BR>
           7:30-4:30 M-F
          </FONT>
         </P>
        </TD>
       </TR>
       <TR>
        <TD class=ten-px-pad-cen colSpan=2>
         <P align=center>
         <IMG height=47 alt="United States Department of Agriculture Forest Service." 
          src="/local_resources/images/logos/usda-fs-shield.gif" width=118 useMap=#logos border=0>
         </P>
         <MAP id=logos name=logos><AREA title="USDA Link" 
          shape=RECT alt="USDA Link" coords=0,1,66,48 
          href="http://www.usda.gov/">
          <AREA title="Forest Service Link" 
          shape=RECT alt="Forest Service Link" coords=69,2,135,57 
          href="http://www.fs.fed.us/">
         </MAP>
        </TD>
       </TR>
      </TBODY>
     </TABLE>
<!-- #EndLibraryItem -->
<!-- TABLE 4.2  - SECONDARY NAVIGATION TABLE STOP -->
<!-- TABLE 4.3 STATION ADRESS TABLE START -->
<!-- TABLE 4.3 - STATION ADRESS TABLE STOP -->
    </TD>
<!-- MAIN NAVIGATION CELL WITH TWO NESTED TABLES STOP -->
<!-- MAIN CONTENT CELL WITH CONTENT ANCHOR START -->
    <TD id=main-table-right-cell align=left bgColor=#ffffff colSpan=2> 
      <!-- DO NOT REMOVE THIS CONTENT ANCHOR. -->
      <A name=content></A> 
      <!-- MAIN PAGE INFO STARTS HERE -->
      <!-- #BeginEditable "content" --> 
      <!-- ***************************************************************************************** -->
      <!-- ***************************************************************************************** -->

      <A href="http://forest.moscowfsl.wsu.edu/BAERTOOLS/">BAER Tools</A> -&gt; 
      <a href="../../">Post-Fire Road Treatment Tools</a> -&gt;
      <a href="../">Post-Fire Peak Flow and Erosion Estimation</a> -&gt;
      Curve Number Methods
      <FONT size=+1> 
       <HR>
      </FONT> 
      <p><font size="+1">Curve Number Methods</font></p>
      <p>
       <br>
      </p>
      <p>The <a href="supplement.html#Details" target="_blank">NRCS curve number methods</a>
        are the second most commonly used post-fire runoff estimation 
        method by BAER team members (<a href="../supplement.html#Preference" target="_blank">30%</a>) 
        (<a href="#Foltz2008">Foltz and others, 2008</a>), and was developed by 
        the U.S. Department of Agriculture Natural Resources Conservation Service 
        (NRCS), formerly the Soil Conservation Service (SCS), to estimate runoff depth.</p>
      <p>&nbsp;</p>
      <p>To use NRCS curve number methods, you will need
       <b><font size="+1">
        <a href="supplement.html#Wildcat4" target="_blank">WILDCAT4</a></font></b> 
        or
        <b><font size="+1">
         <a href="supplement.html#FireHydro" target="_blank">FIRE HYDRO</a></font></b>.
      </p>
      <p>&nbsp;</p>
      <p><b>Input Requirement</b> (<a href="#SCS1991">USDA SCS, 1991</a>)</p>
      <ul type="disc">
        <li>Drainage area;</li>
        <li>Rainfall amount;</li>
        <li><a href="supplement.html#SoilGroups" target="_blank">Hydrologic Soil Groups (A, B, C, and D)</a>;</li>
        <li>Average watershed slope;</li>
        <li>Flow length; and,</li>
        <li>Pre-fire and post-fire runoff curve numbers (CNs).</li>
      </ul>
      <p>&nbsp;</p>
      <p><b><a href="supplement.html#CNGuideline" target="_blank">Use of Post-Fire CNs by BAER Specialists</a></b></p>
      <ul>
        <li><a href="supplement.html#CNCerrelli" target="_blank">Cerrelli (2005)</a> for Region 1</li>
        <li><a href="supplement.html#CNStory" target="_blank">Story (2003)</a> for Region 1</li>
        <li><a href="supplement.html#CNStuart" target="_blank">Stuart (2000)</a> for Region 1</li>
        <li><a href="supplement.html#CNKuyumjian" target="_blank">Kuyumjian</a> for Region 3</li>
        <li><a href="supplement.html#CNLivingston" target="_blank">Livingston and others (2005)</a> for Region 3</li>
        <li><a href="supplement.html#CNFS" target="_blank">U.S. Forest Service Coronado National Forest (2003)</a> for Region 3</li>
        <li><a href="supplement.html#CNHigginson" target="_blank">Higginson and Jarnecke (2007)</a> for Region 4</li>
        <li><a href="supplement.html#CNSolt" target="_blank">Solt and Muir (2006)</a> for Region 4</li>
      </ul>
      <p align="left">&nbsp;</p>
      <p>A<b>dvantages</b></p>
      <ul>
        <li>Applicable for input to methods that calculate peak flow.</li>
        <li>Two CN methods and models (<a href="supplement.html#Wildcat4">WILDCAT4</a> 
          and <a href="supplement.html#FireHydro">FIRE HYDRO</a>) available for 
          post-fire application.</li>
        <li>WILDCAT4 can consider shorter duration storm (e.g., 15 minute) to 
          24-hour storm duration.</li>
      </ul>
      <p>&nbsp;</p>
      <p><b>Disadvantages</b></p>
      <ul>
        <li>Does not estimate erosion.</li>
        <li>Does not consider post-fire debris flow/torrent.</li>
        <li>Applicable to smaller watersheds (&lt; 5 mile<sup>2</sup>).</li>
        <li>FIRE HYDRO <a href="supplement.html#24Hour" target="_blank">only considers 24-hour storm duration</a>.</li>
        <li>User has to determine <a href="supplement.html#PrePostCNs" target="_blank">pre-fire and post-fire CNs</a>.</li>
        <li>No guidelines to determine post-fire CN except for Region 1 and 3.</li>
        <li>Difficulty in combining runoff from areas of different CNs within a watershed</li>
        <li>Will likely <a href="supplement.html#UnderestimateRO" target="_blank">underestimate runoff</a>.</li>
        <li>Uses only English units.</li>
      </ul>
      <p>&nbsp;</p>
      <p><b>Example Results</b><br>
      </p>
      <blockquote> 
        <p><a href="Example/" target="_blank">The 2005 Blackerby Fire in the Nez Perce National Forest, Idaho</a></p>
      </blockquote>
      <p>&nbsp;</p>
      <p>REFERENCES</p>
      <blockquote> 
        <p><a name="SCS1991"></a>U.S. Department of Agriculture, Soil Conservation 
          Service. 1991. Engineering field handbook: chapter 2--estimating runoff. 
          In: National engineering handbook. Washington, D.C.: U.S. Department 
          of Agriculture, Soil Conservation Service: part&nbsp;650.</p>
        <p><a name="Foltz2008"></a>Foltz, Randy B.; Robichaud, Peter R.; Rhee, 
          Hakjun. 2008. A synthesis of post-fire road treatments for BAER teams: 
          methods, treatment effectiveness, and decision-making tools for rehabilitation. 
          Gen. Tech. Rep. RMRS-GTR. Fort Collins, CO: U.S. Department of Agriculture, 
          Forest Service, Rocky Mountain Research Station (<i>in preparation</i>). 
        </p>
        <p>&nbsp;</p>
      </blockquote>

<!-- ***************************************************************************************** -->
<!-- ***************************************************************************************** -->
<!-- #EndEditable --> 
<!-- MAIN PAGE INFO STOPS HERE -->
     </TD>
<!-- MAIN CONTENT CELL WITH CONTENT ANCHOR STOP -->
    </TR>
<!-- ROW 4.0A - MAIN LAYOUT TABLE STOP -->
<!-- ROW 5.0 - FOOTER LAYOUT TABLE START 
	  TAB INDEX: NONE
	  INCLUDES:
		 LINK TO TOP OF PAGE
		 DISCLAIMER, PRIVACY, AND PRINT LINKS
		 ROUND IMAGE LOWER RIGHT CORNER  -->
    <TR>
     <TD id=footer-table-left-cell height=25><A href="#top">top</A></TD>
     <TD id=footer-table-right-cell colSpan=2>
      <DIV><!-- #BeginLibraryItem "/Library/footer-disclaimers.lbi" -->
       <A tabIndex=50 href="/about/disclaimers.shtml">Disclaimers</A>&nbsp;|&nbsp;<A tabIndex=51 href="/about/privacy.shtml">Privacy Policy</A> 
<!-- #EndLibraryItem -->
      </DIV>
     </TD>
    </TR>
<!-- ROW 5.0 - FOOTER LAYOUT TABLE STOP -->
<!-- ROW 6.0 - LAST MODIFIED INFORMATION - START  -->
<!-- TAB INDEX: NONE  -->
<!-- INCLUDES:  This Is An Optional Row - Last Modified For Sites Residing On The WO National Public Web Server -->
    <TR>
     <TD colSpan=3><!-- #BeginLibraryItem "/Library/footer2-last-mod-ssi.lbi" -->
      <P class=modified>USDA Forest Service - RMRS - Moscow Forestry Sciences 
      Laboratory<BR>Last Modified:&nbsp;
      <SCRIPT>
       document.write( document.lastModified )
      </SCRIPT>
       <BR>
      </P>
      <BR><!-- #EndLibraryItem -->
     </TD>
    </TR><!-- ROW 6.0 - LAST MODIFIED INFORMATION - STOP -->
   </TBODY>
  </TABLE>
<!-- IMAGE MAPS -->
  <MAP id=logos>
   <AREA shape=RECT alt="USDA logo which links to the department's national site." coords=-13,-5,65,45 href="http://www.usda.gov/">
   <AREA shape=RECT alt="Forest Service logo which links to the agency's national site." coords=68,1,120,48 href="http://www.fs.fed.us/">
  </MAP>
 </BODY>
    <!-- #EndTemplate -->
    <!-- #EndTemplate -->
</HTML>
