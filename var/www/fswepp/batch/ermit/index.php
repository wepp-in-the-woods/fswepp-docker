<html>
 <head>
  <title>Batch ERMiT interface spreadsheet</title>
     <style>
         body {
             font-family: Calibri, Trebuchet, Tahoma, Arial, sans-serif;
             background-color: ivory;
             color: black;
             margin: 20px;
         }
         a:link {
             color: green;
         }
         a:visited {
             color: lightgreen;
         }
         .instructions {
             border: 1px solid #e0e0e0;
             padding: 15px;
             margin-bottom: 20px;
         }
     </style>
 </head>
 <body>
   <h3>Batch ERMiT interface spreadsheet</h3>
    <blockquote>
    Download Batch ERMiT interface spreadsheet (Note: pre-2017 versions no longer work)
    <ul>
     <li>Version <a href="spreadsheets/ERMiT_Batch_20220322.xlsm">2022.03.22</a> (2.2 MB .xlsm file) for burned and unburned conditions &amp; PEP &ndash; Windows 10 and Excel 2016-compatible with rock % import</li>
     <li>Version <a href="spreadsheets/ERMiT_Batch_2018-04-01.xlsm">2018.04.01</a> (2.2 MB .xlsm file) for burned and unburned conditions &amp; PEP &ndash; Windows 10 and Excel 2016-compatible</li>
     <li>Version <a href="spreadsheets/ERMiT_Batch_20170203-https_modif-production.xls">2017.02.03</a> (2.4 MB .xls file) for burned and unburned conditions &amp; PEP</li>
    </ul>
    <font color=crimson><i>We welcome any feedback you have.</i></font>
    <br><br>
Some hillslopes, especially for unburned conditions, produce a truncated ERMiT results page, which creates an "Error 5" and halts the batch run.<br>
We are working on making the spreadsheet more robust.
    <br><br>
    This spreadsheet is designed to make running multiple ERMiT scenarios much more efficient.
    The spreadsheet interface is downloaded and run on one's PC, but the ERMiT model runs are on our server.
    <br><br>

    <?php include "../requirements.php"; ?>
    <?php include "../optional.php"; ?>
    <?php include "../enable_macros.php"; ?>

    <h4>Hints</h4>
     <ol>
      <li><b>View</b> &ndash;&gt; <b>Full Screen</b> to display (more of) the entry fields
         (right-click on spreadsheet border and <b>Restore</b> to get menus back)</li>
      <li>Use the zoom tool</li>
      <!-- A flat hillslope halts all results &ndash; all the hillslopes are modeled, but no results are displayed -->
      <li>Hillslope horizontal length limit is 1,000 feet (300 meters) in the interface</li>
      <li>Keep a clean version of the interface spreadsheet, and make a copy for each project &ndash;
          save it under a different name before running the batch, and again after to save the results.</li>
      <li>Some hillslopes, especially for unburned conditions, produce a truncated ERMiT results page, which creates an "Error 5" and halts the batch run.
          We are working on making the spreadsheet more robust.</li>
     </ol>
    <br>
    Send us comments<br>
    <a href="/fswepp/comments.html" target="_comment">
     <img src="/fswepp/images/epaemail.gif" align="right" border=0>
    </a>
   </blockquote>
   <img src="/fswepp/images/rmrs_logo_tiny.jpg" width=100><br><br>
   <img src="/fswepp/images/herrera.jpg" width=162 height=46>
   <br><br>
 </body>
</html>
