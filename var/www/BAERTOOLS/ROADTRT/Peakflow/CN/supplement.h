<HTML xmlns="http://www.w3.org/1999/xhtml">
 <!-- #BeginTemplate "/Templates/index.dwt" -->
 <HEAD>
  <!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3c.org/TR/1999/REC-html401-19991224/loose.dtd">
  <!-- saved from url=(0046)http://forest.moscowfsl.wsu.edu/BAERTOOLS/VAR/ --><!-- #BeginTemplate "/Templates/home_deh.dwt" --><HEAD>
  <!-- #BeginEditable "doctitle" --> 
  <TITLE>RMRS - BAER Road Treatment Tools - Curve Number Methods Supplement</TITLE>
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

      <a name="Details"></a>
      <A href="http://forest.moscowfsl.wsu.edu/BAERTOOLS/">BAER Tools</A> -&gt;
      <a href="../../">Post-Fire Road Treatment Tools</a> -&gt;
      <a href="../">Post-Fire Peak Flow and Erosion Estimation</a> -&gt;
      <a href="./">Curve Number Methods </a>-&gt;
      Supplement
      <FONT size=+1> 
       <HR>
      </FONT> 
      <p><b>Details of Curve Number Methods</b></p>
      <p>The curve number methods consider rainfall, soils, cover type, treatment/conservation 
        practices, hydrologic conditions, and topography (slope steepness). Users 
        have to choose a curve number (CN) based on cover type, treatment, hydrologic 
        conditions, and Hydrologic Soil Group to estimate runoff and peak flow; 
        therefore, the curve number is a single most important parameter in this method.</p>
      <p>&nbsp;</p>
      <p><b><a name="Wildcat4"></a>WILDCAT 4</b></p>
      <p>WILDCAT4 (<a href="#Hawkins1990">Hawkins and Greenberg, 1990</a>) is 
        an MS DOS program and a storm runoff/hydrograph model, using triangular 
        unit hydrographs. The WILDCAT4 model requires the following information:</p>
      <ul type="disc">
        <li>Name of the watershed,</li>
        <li>The average land slope (%) and the length of the longest channel (ft), 
          or the <a href="#Tc">time of concentration</a> (hr),</li>
        <li>The area (acres) of Hydrologic Response Unit (HRU; area of the same hydrologic response),</li>
        <li>The CN of HRU,</li>
        <li>Storm duration (hrs),</li>
        <li>Storm rainfall depth (inches), and </li>
        <li>Storm distribution type, either SCS Type II, Farmer-Fletcher (for 
          central and north-central Utah; <a href="#Farmer1972">Farmer and Fletcher, 1972</a>),
          uniform, custom, or generic. If a "generic" distribution is chosen,
          the following information is needed: the minimum and maximum 
          storm intensities (as a percent of the mean storm intensity), and the 
          timing of the peak flow intensity (as a percent of the storm duration).</li>
      </ul>
      <p><a name="Tc"></a>WILDCAT4 tends to have long times of concentration (Tc). 
        If a shorter Tc is preferred, the user mayput a substitute in the Tc formula 
        below (<a href="#Dunne1978">Dunne and Leopold, 1978</a>), which will generate 
        a higher peak flow due to a quicker watershed response to the storm events.</p>
      <p>&nbsp;</p>
      <table width="600" border="0" cellspacing="0" cellpadding="0">
       <tr>
        <td width="40">&nbsp;</td>
        <td colspan="4">
         <span class="style2 style2">
          <em><font size="+1">
           Tc = L<sup> 1.15</sup> / (7700 H <sup>0.38</sup>)
          </font></em>
         </span>
        </td>
       </tr>
       <tr>
        <td width="40">&nbsp;</td>
        <td width="40">&nbsp;</td>
        <td colspan="3">&nbsp;</td>
       </tr>
       <tr>
        <td width="40">&nbsp;</td>
        <td width="40">&nbsp;</td>
        <td colspan="3">where</td>
       </tr>
       <tr>
        <td width="80" colspan="2">&nbsp;</td>
        <td width="20"><i>Tc</i></td>
        <td width="20">=</td>
        <td width="480">time of concentration (hr);</td>
       </tr>
       <tr>
        <td width="80" colspan="2">&nbsp;</td>
        <td width="20"><i>L</i></td>
        <td width="20">=</td>
        <td width="480">length of the catchment along the mainstream from the 
            basin outlet to the most distant ridge (ft); and,</td>
       </tr>
       <tr>
        <td width="80" colspan="2">&nbsp;</td>
        <td width="20"><em>H</em></td>
        <td width="20">=</td>
        <td width="480">difference in elevation between the basin outlet and the most distant ridge (ft).</td>
       </tr>
      </table>
      <p>&nbsp;</p>
      <p>WILDCAT4 is recommended for watersheds of 5 mile<sup>2</sup> or less. 
        WILDCAT4 is easy to use. However, the user has to specify the CN of pre- 
        and post-fire conditions, and the program runs in DOS. WILDCAT5, a Windows 
        version of WILDCAT program, is in development, and will be released in 
        the near future (personal communication, Hawkins, 2008).</p>
      <p>&nbsp;</p>
      <p><b><a name="FireHydro"></a>FIRE HYDRO</b></p>
      <p><a href="#Cerrelli2005">Cerrelli (2005)</a> developed a spreadsheet, 
        called FIRE HYDRO, to assist NRCS and Forest Service personnel to estimate 
        design peak flows for the burned areas of Montana. FIRE HYDRO is a peak 
        flow analysis tool for 2, 5, 10, 25, 50, and 100 year, 24 hour rainfall-runoff 
        events for the pre- and post-fire conditions. The required input data 
        includes the following: drainage area (acre); average watershed slope 
        (%); CN; and 2 to 100 year, 6 and 24 hour rainfall depths which are available 
        from <a href="#NOAA2008">NOAA (2008)</a>. The 6 and 24 hour rainfall depths 
        are required to determine SCS rainfall distribution type (Type I, IA, 
        II, or III). Most of Region 1, including Montana, has Type II that produces 
        the highest peak flow among the SCS rainfall distribution types. Cerrelli 
        (2005) assumed that the runoff curve numbers of <em>bare soil</em> cover 
        type or <em>poor</em> hydrologic condition were used for post-fire conditions. 
        However, there is no clear guideline to choose post-fire runoff curve numbers.
 <a name="24Hour"></a>
        FIRE HYDRO is applicable for 24 hour rainfall events only,
        and not applicable for short duration rainfall events such as an one hour storm or less.</p>
      <p align="left">&nbsp;</p>
      <p align="left"><a name="SoilGroups"></a><b>Hydrologic Soil Groups</b>
       (<a href="#SCS1991">USDA SCS, 1991</a>)</p>
      <p align="left">&nbsp;</p>
      <table width="600" border="0" cellspacing="0" cellpadding="0">
       <tr>
        <td width="100"><div align="center">Group</div></td>
        <td><div align="center">Description</div></td>
        <td width="100"><div align="center">Minimum infiltration rate</div></td>
       </tr>
       <tr>
        <td width="100"><div align="center"></div></td>
        <td><div align="center"></div></td>
        <td width="100"><div align="center">(inch/h)</div></td>
       </tr>
       <tr>
        <td colspan="3"><hr noshade></td>
       </tr>
       <tr>
        <td width="100"><div align="center">A</div></td>
        <td>Low runoff potential and high infiltration rates, and consist chiefly of sands and gravels</td>
        <td width="100"><div align="center">&gt; 0.30</div></td>
       </tr>
       <tr bgcolor="#CCCCCC">
        <td width="100"><div align="center">B</div></td>
        <td>Moderate infiltration rates, and moderately fine to moderately coarse texture</td>
        <td width="100"><div align="center">0.15-0.30</div></td>
       </tr>
       <tr>
        <td width="100"><div align="center">C</div></td>
        <td>Low infiltration rates, and consist chiefly of soils having a layer
            that impedes downward movement of water and soils of moderately fine to fine texture</td>
        <td width="100"><div align="center">0.05-0.15</div></td>
       </tr>
       <tr bgcolor="#CCCCCC">
        <td width="100"><div align="center">D</div></td>
        <td>High runoff potential and very low infiltration rates, and consist mainly of clay soils, soils with a 
            permanent high water table, or shallow soils over nearly impervious material</td>
        <td width="100"><div align="center">&lt; 0.05</div></td>
       </tr>
      </table>
      <p align="left">&nbsp;</p>
      <p align="left"><a name="CNGuideline"></a><b>Use of Post-Fire CNs by BAER Specialists </b></p>
      <p align="left">There are limited numbers of studies that provide post-fire 
        runoff curve numbers. <a href="#Spring2005">Springer and Hawkins (2005)</a> 
        attempted to provide a guideline to choose post-fire runoff curve number 
        based on the 2000 Cerro Grande Fire, New Mexico and concluded that
        <em>
         "the post-fire trends in CN and peak flows are not readily explained and will be a topic of future research."
        </em>
        Since there are very limited studies and guidelines to choose CNs for post-fire conditions, often BAER team 
        members use simple rules of their own.</p>
      <p align="left">&nbsp;</p>
      <p align="left"><a name="CNCerrelli"></a><b>Cerrelli (2005)</b></p>
      <p align="left"><a href="#Cerrelli2005">Cerrelli (2005)</a> provided a guideline 
        to select post-fire CN based on the Bitterrot National Forest wildfires. 
        His initial search of the literature for CN values for burned areas in 
        southwestern Montana was did not find appropriate CNs. Consequently, Montana 
        NRCS engineers created a guideline based on the existing NRCS CN/land 
        use table. However, no gaging or calibrating took place to verify or improve 
        this guideline. The 2-year to 5-year, 24-hour storm events occurred in 
        the following spring and summer. Runoff from these storm events did not 
        cause failure of the protection practices assessed and implemented using 
        this CN guideline.</p>
      <p align="left">&nbsp;</p>
      <table width="600" border="0" cellspacing="0" cellpadding="0">
       <tr>
        <td width="200">            <div align="center">Soil burn severity</div>          </td>
        <td width="200">             <div align="center">Sub-category</div>          </td>
        <td width="200">             <div align="center">Estimated CN</div>          </td>
       </tr>
       <tr> 
        <td colspan="3">             <hr>          </td>
       </tr>
       <tr>
        <td width="200">             <div align="center">High<sup>1</sup></div>          </td>
        <td width="200">             <div align="center">HSG<sup>2</sup> A</div>          </td>
        <td width="200">             <div align="center">64</div>          </td>
       </tr>
       <tr bgcolor="#CCCCCC"> 
        <td width="200">             <div align="center"></div>          </td>
        <td width="200">             <div align="center">HSG B</div>          </td>
        <td width="200">             <div align="center">78</div>          </td>
       </tr>
       <tr>
        <td width="200">             <div align="center"></div>          </td>
        <td width="200">             <div align="center">HSG C</div>          </td>
        <td width="200">             <div align="center">85</div>          </td>
       </tr>
       <tr bgcolor="#CCCCCC"> 
        <td width="200">             <div align="center"></div>          </td>
        <td width="200">             <div align="center">HSG D</div>          </td>
        <td width="200">             <div align="center">88</div>          </td>
       </tr>
       <tr>
        <td width="200">             <div align="center">Moderate</div>          </td>
        <td width="200">             <div align="center"></div>          </td>
        <td width="200">             <div align="center">Use cover type<sup>3</sup> in Fair condition</div></td>
       </tr>
       <tr bgcolor="#CCCCCC"> 
        <td width="200">             <div align="center">Low and unburned</div>          </td>
        <td width="200">             <div align="center">North and East facing slopes</div>          </td>
        <td width="200">             <div align="center">Use cover type in Good condition</div>          </td>
       </tr>
       <tr>
        <td width="200">             <div align="center"></div>          </td>
        <td width="200">             <div align="center">South and West facing slopes</div>          </td>
        <td width="200">             <div align="center">Use cover type between Fair and Good condition</div></td>
       </tr>
       <tr bgcolor="#CCCCCC"> 
        <td width="200">             <div align="center">Any</div>          </td>
        <td width="200">             <div align="center">Water repellent soils</div>          </td>
        <td width="200">             <div align="center"><sup>4</sup>94</div>          </td>
       </tr>
      </table>
     <p align="left">&nbsp;</p>
      <table width="600" border="0" cellspacing="0" cellpadding="0">
        <tr>
          <td width="10"><sup>1</sup></td>
          <td width="590">High burn severity areas were assumed to have attained 
            at least 30% ground cover consisting of vegetation, duff, thick ash, 
            or woody debris by June of the following year after the fire, and 
            the CN values were from three Montana NRCS engineers with hydrologic 
            evaluation experience. </td>
        </tr>
        <tr>
          <td width="10"><sup>2</sup></td>
          <td width="590"><a href="#SoilGroups">Hydrologic Soil Group</a></td>
        </tr>
        <tr>
          <td width="10"><sup>3</sup></td>
          <td width="590">Refer to <a href="#SCS1991">USDA SCS (1991)</a></td>
        </tr>
        <tr>
          <td width="10"><sup>4</sup></td>
          <td width="590">Rule of thumb by Montana NRCS</td>
        </tr>
      </table>
      <p align="left">&nbsp;</p>
      <p><b><a name="CNStory"></a>Story (2003)</b></p>
      <p><a href="#Story2003">Story (2003)</a> circulated an e-mail to suggest the following post-fire CNs for Region 1.</p>
      <p>&nbsp;</p>
      <table width="600" border="0" cellspacing="0" cellpadding="0">
       <tr> 
        <td width="10">&nbsp;</td>
        <td> Post-fire condition</td>
        <td width="200">             <div align="center">Range of CN values</div>          </td>
       </tr>
       <tr> 
        <td colspan="3">             <hr noshade>          </td>
       </tr>
       <tr> 
        <td width="10">&nbsp;</td>
        <td>High burn severity with water repellent soils</td>
        <td width="200">             <div align="center">93-98</div>          </td>
       </tr>
       <tr> 
        <td width="10">&nbsp;</td>
        <td> High burn severity without water repellent soils</td>
        <td width="200">             <div align="center">90-95</div>          </td>
       </tr>
      </table>
      <p>&nbsp;</p>
      <p><a name="CNStuart"></a><b>Stuart (2000)</b></p>
      <p><a href="#Stuart2000">Stuart (2000)</a> used FIRE HYDRO
         <a href="#Cerrelli2005">(Cerrelli, 2005)</a>
        to estimate storm event peak flow on the 2000 Maudlow Fire, 
        Montana. Based on observations of unburned conditions, land type/cover 
        type, burn intensity, and water repellency conditions, the following CNs were selected.</p>
      <p>&nbsp;</p>
      <table width="600" border="0" cellspacing="0" cellpadding="0">
       <tr> 
        <td width="10">&nbsp;</td>
        <td> Post-fire condition<sup>1</sup></td>
        <td width="200">             <div align="center">Range of CN values</div>          </td>
       </tr>
       <tr> 
        <td colspan="3">             <hr noshade>          </td>
       </tr>
       <tr> 
        <td width="10">&nbsp;</td>
        <td>Moderate burn severity</td>
        <td width="200">             <div align="center">80</div>          </td>
       </tr>
       <tr bgcolor="#CCCCCC"> 
        <td width="10">&nbsp;</td>
        <td>Low burn severity</td>
        <td width="200">             <div align="center">70-72</div>          </td>
       </tr>
       <tr> 
        <td width="10">&nbsp;</td>
        <td>Unburned</td>
        <td width="200">             <div align="center">60-64</div>          </td>
       </tr>
       <tr bgcolor="#CCCCCC"> 
        <td width="10">&nbsp;</td>
        <td>Moderate burn severity with BAER treatments<sup>2</sup></td>
        <td width="200">             <div align="center">75</div>          </td>
       </tr>
       <tr> 
        <td width="10">&nbsp;</td>
        <td>Low burn severity with BAER treatments</td>
        <td width="200">             <div align="center">66</div>          </td>
       </tr>
      </table>
      <p>&nbsp;</p>
      <table width="600" border="0" cellspacing="0" cellpadding="0">
       <tr> 
        <td width="10"><sup>1</sup></td>
        <td width="590">There was no high burn severity area in the Maudlow Fire area.</td>
       </tr>
       <tr> 
        <td width="10"><sup>2</sup></td>
        <td width="590">The combination of seeding, contour-felling, fencing, and road drainage would reduce CN.</td>
       </tr>
      </table>
      <p>&nbsp;</p>
      <p><a name="CNKuyumjian"></a><b>Kuyumjian, Greg. [Personal note]. Greg's Curve Number thoughts.</b></p>
      <p>&nbsp;</p>
      <table width="600" border="0" cellspacing="0" cellpadding="0">
       <tr> 
        <td width="10">&nbsp;</td>
        <td> Post-fire condition</td>
        <td width="200">             <div align="center">Range of CN values</div>          </td>
       </tr>
       <tr> 
         <td colspan="3">             <hr noshade>          </td>
       </tr>
       <tr> 
        <td width="10">&nbsp;</td>
        <td>High burn severity with water repellent soils </td>
        <td width="200">           <div align="center">95</div>          </td>
       </tr>
       <tr bgcolor="#CCCCCC">
        <td width="10">&nbsp;</td>
        <td>High burn severity without water repellent soils</td>
        <td width="200">             <div align="center">90-91</div>          </td>
       </tr>
       <tr> 
        <td width="10">&nbsp;</td>
        <td>Moderate burn severity with water repellent soils</td>
        <td width="200">           <div align="center">90</div>          </td>
       </tr>
       <tr bgcolor="#CCCCCC"> 
        <td width="10">&nbsp;</td>
        <td>Moderate burn severity without water repellent soils</td>
        <td width="200">             <div align="center">85</div>          </td>
       </tr>
       <tr> 
        <td width="10">&nbsp;</td>
        <td>Low burn severity</td>
        <td width="200">             <div align="center">Pre-fire CN + 5</div>          </td>
       </tr>
       <tr bgcolor="#CCCCCC"> 
        <td width="10">&nbsp;</td>
        <td>Straw mulch with good coverage</td>
        <td width="200">             <div align="center">60</div>          </td>
       </tr>
       <tr> 
        <td width="10">&nbsp;</td>
        <td>Seeding with LEBs<sup>1</sup>--one year after fire</td>
        <td width="200">             <div align="center">75</div>          </td>
       </tr>
       <tr bgcolor="#CCCCCC"> 
        <td width="10">&nbsp;</td>
        <td>LEBs without water repellent soils</td>
        <td width="200">            <div align="center">85</div>          </td>
       </tr>
      </table>
      <p>&nbsp;</p>
      <table width="600" border="0" cellspacing="0" cellpadding="0">
       <tr> 
        <td width="10"><sup>1</sup></td>
        <td width="590">Log Erosion Barriers</td>
       </tr>
      </table>
      <p>&nbsp;</p>
      <p align="left"><b><a name="CNLivingston"></a>Livingston and others (2005)</b></p>
      <p><a href="#Livingston2005">Livingston and others (2005)</a> provided a 
        guideline to choose the post-fire CNs with a range of values. They used 
        computed CNs and compared pre-and post-fire CNs for 31 small (0.12 to 
        2.5 mile<sup>2</sup>) subbasins in the Los Alamos area in New Mexico and 
        24 small (0.11 to 2.3 mile<sup>2</sup>) subbasins affected by the 2002 
        Long Mesa Fire at Mesa Verde National Park in Colorado. Their study results 
        are applicable to the Los Alamos area and other areas in the southwest 
        with similar pre-fire CN values and hydrology; however, they are not applicable 
        to areas with different pre-fire rainfall and runoff characteristics. 
      </p>
      <p>&nbsp;</p>
      <table width="600" border="0" cellspacing="0" cellpadding="0">
       <tr> 
        <td width="10">&nbsp;</td>
        <td width="390">Soil burn severity</td>
        <td width="200">             <div align="center">Estimated CN</div>          </td>
       </tr>
       <tr> 
        <td colspan="3">             <hr noshade>          </td>
       </tr>
       <tr> 
        <td width="10">&nbsp;</td>
        <td width="390">High, with water repellent soils</td>
        <td width="200">             <div align="center">95</div>          </td>
       </tr>
       <tr bgcolor="#CCCCCC"> 
        <td width="10">&nbsp;</td>
        <td width="390">High, without water repellent soils</td>
        <td width="200">             <div align="center">92</div>          </td>
       </tr>
       <tr> 
        <td width="10">&nbsp;</td>
        <td width="390">Moderate, with water repellent soils</td>
        <td width="200">             <div align="center">89</div>          </td>
       </tr>
       <tr bgcolor="#CCCCCC"> 
        <td width="10">&nbsp;</td>
        <td width="390">Moderate, without water repellent soils</td>
        <td width="200">             <div align="center">87</div>          </td>
       </tr>
       <tr> 
        <td width="10">&nbsp;</td>
        <td width="390">Low</td>
        <td width="200">             <div align="center">80-83</div>          </td>
       </tr>
       <tr bgcolor="#CCCCCC"> 
        <td width="10">&nbsp;</td>
        <td width="390">Unburned</td>
        <td width="200">             <div align="center">55-75</div>          </td>
       </tr>
      </table>
      <p>&nbsp;</p>
      <p>To classify the soil burn severity of the whole watershed/basin, they 
        used Wildfire Hydrologic Impact (WHI), based on the percentage of high 
        and moderate soil burn severity, and a general relation between pre- and 
        post-fire CN ratio. The WHI can be determined using the table or figure 
        below.</p>
      <p>&nbsp;</p>
      <table width="600" border="0" cellspacing="0" cellpadding="0">
       <tr> 
        <td width="10">&nbsp;</td>
        <td width="295">             <div align="center">Percentage of subbasins </div>          </td>
        <td width="295">             <div align="center">Wildfire Hydrologic Impact</div>          </td>
       </tr>
       <tr> 
        <td width="10">&nbsp;</td>
        <td width="295">             <div align="center">with a high soil burn severity</div>          </td>
        <td width="295">             <div align="center">classification</div>          </td>
       </tr>
       <tr> 
        <td colspan="3">             <hr noshade>          </td>
       </tr>
       <tr>
        <td width="10">&nbsp;</td>
        <td width="295">             <div align="center">49-80</div>          </td>
        <td width="295">             <div align="center">Severe</div>          </td>
       </tr>
       <tr> 
        <td width="10">&nbsp;</td>
        <td width="295">             <div align="center">7-48</div>          </td>
        <td width="295">            <div align="center">Moderate</div>          </td>
       </tr>
       <tr> 
        <td width="10">&nbsp;</td>
        <td width="295">             <div align="center">0-6</div>          </td>
        <td width="295">            <div align="center">Low</div>          </td>
       </tr>
      </table>
      <p>&nbsp;</p>
      <table width="600" border="0" cellspacing="0" cellpadding="0">
        <tr> 
          <td width="58">&nbsp;</td>
          <td width="483"><img src="WHI.jpg" width="483" height="487" align="top"></td>
          <td width="59">&nbsp;</td>
        </tr>
        <tr> 
          <td width="58">&nbsp;</td>
          <td width="483">After <a href="#Livingston2005">Livingston and others 
            (2005)</a></td>
          <td width="59">&nbsp;</td>
        </tr>
      </table>
      <p>&nbsp;</p>
      <p>Post-fire runoff curve number can be estimated using the figure below if pre-fire CN is known.</p>
      <p>&nbsp;</p>
      <table width="600" border="0" cellspacing="0" cellpadding="0">
       <tr>
        <td width="42">&nbsp;</td>
        <td width="516"><img src="CN_ratio.jpg" width="516" height="731"></td>
        <td width="42">&nbsp;</td>
       </tr>
       <tr> 
        <td width="42">&nbsp;</td>
        <td width="516">After <a href="#Livingston2005">Livingston and others (2005)</a></td>
        <td width="42">&nbsp;</td>
       </tr>
      </table>
      <p>&nbsp;</p>
      <p><a name="CNFS"></a><b>U.S. Forest Service Coronado National Forest (2003)</b></p>
      <p><a href="#FS2003">U.S. Forest Service Coronado National Forest (2003)</a> 
        used WILDCAT4 (<a href="#Hawkins1990">Hawkins and Greenberg, 1990</a>) 
        to estimate peak flow runoff in key watersheds under pre-and post-fire 
        conditions on the 2003 Aspen Fire, Arizona. Limited sampling of water 
        repellency conditions indicated moderate water repellency occurred on 
        severely burned soils. </p>
      <p>&nbsp;</p>
      <table width="600" border="0" cellspacing="0" cellpadding="0">
       <tr> 
        <td width="10">&nbsp;</td>
        <td rowspan="2"><div align="center"><a href="#SoilGroups">Hydrologic soil group</a></div></td>
        <td width="115">            <div align="center">Pre-fire CN</div>          </td>
        <td colspan="3">             <div align="center">Post-fire CN</div>          </td>
       </tr>
       <tr> 
        <td width="10">&nbsp;</td>
        <td width="115">&nbsp;</td>
        <td colspan="3">             <hr noshade>          </td>
       </tr>
       <tr> 
        <td width="10">&nbsp;</td>
        <td width="115">&nbsp;</td>
        <td width="115">&nbsp;</td>
        <td width="120">             <div align="center">High burn severity</div>          </td>
        <td width="120">            <div align="center">Moderate burn severity</div>          </td>
        <td width="120">            <div align="center">Low burn severity</div>          </td>
       </tr>
       <tr> 
        <td colspan="6">             <hr noshade>          </td>
       </tr>
       <tr> 
        <td width="10">&nbsp;</td>
        <td width="115">            <div align="center">B</div>          </td>
        <td width="115">             <div align="center">56</div>          </td>
        <td width="120">             <div align="center">65</div>          </td>
        <td width="120">             <div align="center">--</div>          </td>
        <td width="120">             <div align="center">--</div>          </td>
       </tr>
       <tr> 
        <td width="10">&nbsp;</td>
        <td width="115">             <div align="center">C</div>          </td>
        <td width="115">             <div align="center">67</div>          </td>
        <td width="120">             <div align="center">70--75</div>          </td>
        <td width="120">             <div align="center">80</div>          </td>
        <td width="120">             <div align="center">90</div>          </td>
       </tr>
       <tr> 
        <td width="10">&nbsp;</td>
        <td width="115">             <div align="center">D</div>          </td>
        <td width="115">             <div align="center">77</div>          </td>
        <td width="120">             <div align="center">80--85</div>          </td>
        <td width="120">             <div align="center">90</div>          </td>
        <td width="120">             <div align="center">95</div>          </td>
       </tr>
      </table>
      <p>&nbsp;</p>
      <p><b><a name="CNHigginson"></a>Higginson and Jarnecke (2007)</b></p>
      <p><a href="#Higginson2007">Higginson and Jarnecke (2007</a>) used WILDCAT4 
        (<a href="#Hawkins1990">Hawkins and Greenberg, 1990</a>) to estimate pre- 
        and post-fire runoff on the 2007 Salt Creek Fire, Utah. They used the 
        following rules to determine post-fire CNs. </p>
      <p>&nbsp;</p>
      <table width="600" border="0" cellspacing="0" cellpadding="0">
       <tr> 
        <td width="30">&nbsp;</td>
        <td width="80">             <div align="left">High</div>          </td>
        <td width="120"> burn severity CN</td>
        <td width="20">=</td>
        <td width="130">pre-fire CN + 15</td>
        <td>&nbsp;</td>
       </tr>
       <tr> 
        <td width="30">&nbsp;</td>
        <td width="80">           <div align="left">Moderate</div>          </td>
        <td width="120">burn severity CN</td>
        <td width="20">=</td>
        <td width="130">pre-fire CN + 10</td>
        <td>&nbsp;</td>
       </tr>
       <tr> 
        <td width="30">&nbsp;</td>
        <td width="80">            <div align="left">Low</div>          </td>
        <td width="120"> burn severity CN</td>          <td width="20">=</td>
        <td width="130">pre-fire CN + 5</td>
        <td>&nbsp;</td>
       </tr>
       <tr> 
        <td width="30">&nbsp;</td>
        <td colspan="5">Maximum CN value is 100.</td>
       </tr>
      </table>
      <p>&nbsp;</p>
      <p><b><a name="CNSolt"></a>Solt and Muir (2006)</b></p>
      <p><a href="#Solt2006">Solt and Muir (2006)</a> used WILDCAT4
        (<a href="#Hawkins1990">Hawkins and Greenberg, 1990</a>)
        to estimate pre- and post-fire runoff on the 
        2006 Warm Fire, Utah. The limestone derived soils of the burned area were 
        determined to be in <a href="#SoilGroups">Hydrologic Soil Group</a> D 
        (low infiltration) and in the ponderosa pine/juniper vegetation type. 
        The following CNs were selected. </p>
      <p>&nbsp;</p>
      <table width="600" border="0" cellspacing="0" cellpadding="0">
       <tr> 
        <td width="10">&nbsp;</td>
        <td> Condition</td>
        <td width="200">             <div align="center">CN value</div>          </td>
       </tr>
       <tr> 
        <td colspan="3">             <hr noshade>          </td>
       </tr>
       <tr> 
        <td width="10">&nbsp;</td>
        <td>Pre-fire</td>
        <td width="200">             <div align="center">80</div>          </td>
       </tr>
       <tr bgcolor="#CCCCCC"> 
        <td width="10">&nbsp;</td>
        <td>High burn severity</td>
        <td width="200">             <div align="center">90</div>          </td>
       </tr>
       <tr> 
        <td width="10">&nbsp;</td>
        <td>Moderate burn severity</td>
        <td width="200">             <div align="center">85</div>          </td>
       </tr>
       <tr bgcolor="#CCCCCC"> 
        <td width="10">&nbsp;</td>
        <td>Low burn severity and unburned</td>
        <td width="200">             <div align="center">80</div>          </td>
       </tr>
      </table>
      <p>&nbsp;</p>
      <p><b><a name="PrePostCNs"></a>Pre- and Post-Fire CNs</b></p>
      <p>The user has to determine pre-fire and post-fire CN, which is a sensitive 
        parameter; therefore, the estimated peak flow is subjective to users. 
      </p>
      <p>&nbsp;</p>
      <p><a name="UnderestimateRO"></a><b>Underestimation of Post-Fire Runoff</b></p>
      <p>Once the user has determined CNs for each HRU within a watershed, the 
        problem of how to combine them arises. Curve Numbers and runoff depth 
        are not linearly related, but curvilinearly related
        <a href="#Grove1998">(Grove and others, 1998</a>).
        A weighted average of all CNs in a watershed is 
        commonly used to reduce the number of calculations. The underestimation 
        of runoff using weighted average CNs is most severe for wide CN ranges, 
        as would occur in watersheds containing low and high severity burns. Low 
        CN values and low precipitation depths, as would occur in unburned southwestern 
        watersheds would result in underestimation of runoff. Therefore, care 
        should be exercised when applying weighted average CNs.</p>
      <p>Another approach is to use distributed CNs in a GIS application. However, 
        <a href="#White1988">White (1988)</a> and
        <a href="#Stuebe1990">Stuebe and Johnston (1990</a>)
        reported that using distributed CNs resulted in 
        as much as 100 percent higher runoff than when using weighted average CNs.</p>
      <p>The preferred method to estimate runoff from watersheds with different 
        CNs is to combine runoff amounts from each HRU.<br>
      </p>
      <p>&nbsp;</p>
      <p>REFERENCES</p>
      <blockquote> 
        <p><a name="Cerrelli2005"></a>Cerrelli, G. A. 2005. FIRE HYDRO, a simplified 
          method for predicting peak discharges to assist in the design of flood 
          protection measures for western wildfires. In: Moglen, Glenn E., eds. 
          Proceedings: 2005 watershed management conference-managing watersheds 
          for human and natural impacts: engineering, ecological, and economic 
          challenges; 2005 July 19-22; Williamsburg, VA. Alexandria, VA: American 
          Society of Civil Engineers: 935-941. </p>
        <p><a name="Dunne1978"></a>Dunne, Thomas; Leopold, Luna B. 1978. Water 
          in environmental planning. New York, NY: W. H. Freeman and Company. 
          818&nbsp;p.</p>
        <p><a name="Farmer1972"></a>Farmer, E. E.; Fletcher, J. E. 1972. Rainfall 
          intensity-duration-frequency relations for the Wasatch Mountains of 
          northern Utah. Water Resources Research. 8(1): 266-271.</p>
        <p><a name="Grove1998"></a>Grove, Matt; Harbor, Jon; Engel, Bernard. 1998. 
          Composite vs. distributed curve numbers: effects on estimates of storm 
          runoff depths. Journal of the American Water Resources Association. 
          34(5): 1015-1023.</p>
        <p><a name="Hawkins1990"></a>Hawkins, R. H.; Greenberg, R. J. 1990. WILDCAT4 
          Flow Model. [This edition further enhances Moore's version] School of 
          Renewable Natural Resources, University of Arizona, Tucson, AZ. BLM 
          contact: Dan Muller, Denver, CO.</p>
        <p><a name="Higginson2007"></a>Higginson, Brad; Jarnecke, Jeremy. 2007. 
          Salt Creek BAER-2007 Burned Area Emergency Response. Provo, UT: Uinta 
          National Forest; Hydrology Specialist Report. 11&nbsp;p.</p>
        <p><a name="Livingston2005"></a>Livingston, Russell K.; Earles, T. Andrew; 
          Wright, Kenneth R. 2005. Los Alamos post-fire watershed recovery: a 
          curve-number-based evaluation. In: Moglen, Glenn E., eds. Proceedings: 
          2005 watershed management conference-managing watersheds for human and 
          natural impacts: engineering, ecological, and economic challenges; 2005 
          July 19-22; Williamsburg, VA. Alexandria, VA: American Society of Civil 
          Engineers: 471-481.</p>
        <p><a name="NOAA2008"></a>National Oceanic and Atmospheric Administration. 
          (2008, March 19-last update). NOAA's National Weather Service Hydrometeorological 
          Design Stduies Center [Hompage of HDSC], [Online]. Available:
 <a href="http://www.nws.noaa.gov/oh/hdsc/index.html" target="_blank">http://www.nws.noaa.gov/oh/hdsc/index.html</a> 
          [2008, May 6].</p>
        <p><a name="Solt2006"></a>Solt, Adam; Muir, Mark. 2006. Warm Fire--hydrology 
          and watershed report. Richfield, UT: U.S. Department of Agriculture, 
          Forest Service, Intermountain Region, Fishlake National Forest. 9&nbsp;p.</p>
        <p><a name="Spring2005"></a>Springer, Everett P.; Hawkins, Richard H. 
          2005. Curve number and peakflow responses following the Cerro Grande 
          Fire on a small watershed. In: Moglen, Glenn E., eds. Proceedings: 2005 
          watershed management conference-managing watersheds for human and natural 
          impacts: engineering, ecological, and economic challenges; 2005 July 
          19-22; Williamsburg, VA. Alexandria, VA: American Society of Civil Engineers: 459-470.</p>
        <p><a name="Story2003"></a>Story, Mark. 2003. [E-mail circulation]. September. 
          Stormflow methods.</p>
        <p><a name="Stuart2000"></a>Stuart, Bo. 2000. Maudlow Fire, Burned Area 
          Emergency Rehabilitation (BAER) plan. Townsend, MT: U.S. Department 
          of Agriculture, Forest Service, Northern Region, Helena National Forest.</p>
        <p><a name="Stuebe1990"></a>Stuebe, M. M.; Johnston, D. M. 1990. Runoff 
          volume estimation using GIS techniques. Water Resources Bulletin. 26(4): 611-620.</p>
        <p><a name="SCS1991"></a>U.S. Department of Agriculture, Soil Conservation 
          Service. 1991. Engineering field handbook: chapter 2--estimating runoff. 
          In: National engineering handbook. Washington, D.C.: U.S. Department 
          of Agriculture, Soil Conservation Service: part&nbsp;650.</p>
        <p><a name="FS2003"></a>U.S. Forest Service Coronado National Forest. 
          2003. Aspen Fire, Coronado National Forest, BAER hydrology report. Tucson, 
          AZ: U.S. Department of Agriculture, Forest Service, Southwestern Region, 
          Coronado National Forest.</p>
        <p><a name="White1988"></a>White, D. 1988. Grid-based application of runoff 
          curve numbers. Journal of Water Resources Planning and Management. 114(6): 601-612.</p>
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