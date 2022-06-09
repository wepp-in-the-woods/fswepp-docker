<?php
  include ("functions.php");
  include ("presentation.php");
  include ("paper.php");
  
  $default_user = "guest";
  $default_pass = "guest";
  $default_db = "docs";
  $paper_table = "paper";
  $presentation_table = "presentation";

  switch($action)
    {
		// This function displays a form for the administrator to fill for the update of a paper.
    case "edit_paper_form":
      html("top");
      edit_paper_form();
      html("bottom");
    break;

    // This function connects to the database and updates the paper with the information provided
    // from the edit_paper_form.
    case "edit_paper":
      html("top");
      edit_paper();
      html("bottom");
    break;

    // This function connects to the database and deletes the specified paper.
    case "delete_paper":
      html("top");
      delete_paper();
      html("bottom");
    break;

    // This function displays a form for the administrator to fill out for the addition of a paper.
    case "paper_form":
      html("top");
      paper_form();
      html("bottom");
    break;

    // This function connects to the database and adds the paper with the information provided by
    // the paper_form function.
    case "insert_paper":
      html("top");
      insert_paper();
      html("bottom");
    break;

    // This function displays a form for the administrator to fill for the update of a presentation.
		case "edit_presentation_form":
			html("top");
			edit_presentation_form();
		  html("bottom");
		break;

		// This function connects to the database and updates the presentation with the information provided
		// from the edit_presentation_form.
		case "edit_presentation":
		  html("top");
		  edit_presentation();
		  html("bottom");
		break;

		// This function connects to the database and deletes the specified presentation.
		case "delete_presentation":
		  html("top");
		  delete_presentation();
		  html("bottom");
		break;

		// This function displays a form for the administrator to fill out for the addition of a presentation.
		case "presentation_form":
		  html("top");
		  presentation_form();
		  html("bottom");
		break;

		// This function connects to the database and adds the presentation with the information provided by
		// the presentation_form function.
		case "insert_presentation":
		  html("top");
		  insert_presentation();
		  html("bottom");
    break;

    // This displays the data in the database and the administration menu.
    case "view":
      html("top");
      view();
      html("bottom");
    break;

    // This function displays a form for the administrator to login.
    case "login":
      html("top");
      login();
      html("bottom");
    break;

    // This function displays the data in the database with generic access.
    case "webview":
      html("top");
      webview();
      html("bottom");
    break;

    default:
      html("top");
      webview();
      html("bottom");
    break;
    }
?>
