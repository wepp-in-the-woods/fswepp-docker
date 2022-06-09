<?

  function html($dir)

    {

    global $user, $pass;

    if($dir == "top")

      {

      echo "<html><head><title></title></head><link rel=stylesheet href=../css/rmrs.css type=text/css><body bgcolor=cccccc>";

      if($user == "smpdocs")

        {

					echo "<p align=center><a href=$PHP_SELF?action=view&user=$user&pass=$pass>View</a>&nbsp;&nbsp;&nbsp;

					<a href=$PHP_SELF?action=login>Logout</a>&nbsp;&nbsp;&nbsp;

					<a href=$PHP_SELF?action=paper_form&user=$user&pass=$pass>Add Paper</a>&nbsp;&nbsp;&nbsp;

          <a href=$PHP_SELF?action=presentation_form&user=$user&pass=$pass>Add Presentation</a>&nbsp;&nbsp;&nbsp;

					</p>\n";

		    }

		  else

		    {

		    echo "<a href=$PHP_SELF?action=login>Admin Logon</a><br>";

		    }

      }

    else if($dir == "bottom")

      { 

      echo "</body></html>\n";

      }

    }

 

  function login()

    {

    echo "<form method=submit action=$PHP_SELF>

      <input type=hidden name=action value=view>

      <table>

			  <tr>

				  <td colspan=2>

					  Documentation Login

					</td>

				</tr>

        <tr>

          <td width=20>Username:</td>

          <td width=20><input type=text name=user></td>

        </tr>

        <tr>

          <td width=20>Password:</td>

          <td width=20><input type=password name=pass></td>

        </tr>

        <tr>

          <td colspan=2><input type=submit></td>

        <tr>

      </table>

    </form>";

    }



  function con($user, $pass)

    {

		global $default_db;

    $link = mysql_connect("localhost", $user, $pass) or die ($php_errormsg);

    if($link)

      {

      mysql_select_db($default_db, $link) or die ($php_errormsg);

      return $link; 

      }

    else return -1;

    } 

    

  function view_paper()

    {

		global $paper_table, $user, $pass;

		$id = con($user, $pass);

    if($id)

      {

      $query = "SELECT * from $paper_table order by topic ";

      $result = mysql_query($query);

      if($result)

        {

        while($query_data = mysql_fetch_array($result))

          {

          $paper_id = $query_data["paper_id"];

          $author = $query_data["author"];

          $date = $query_data["date"];

          $title = $query_data["title"];

          $journal = $query_data["journal"];

          $topic = $query_data["topic"];

          $link1 = $query_data["link1"];

          $link2 = $query_data["link2"];

          $link3 = $query_data["link3"];

          $link4 = $query_data["link4"];

          $link5 = $query_data["link5"];

          $link6 = $query_data["link6"];

          if($count == 0)

					  {

						echo "<table border width=550><tr><th colspan=5 align=left bgcolor=eeeeee><font size=4>Papers</font></th></tr>";

					  }

					$count++;

          if($topic != $oldtopic)

            {

						echo "<tr><td colspan=5 align=left bgcolor=dddddd><font size=4>Topic: $topic</font></td></tr>";

						$count = 1;

					  }

          $oldtopic = $topic;

          echo "

          <tr bgcolor=#cccccc>

          <td width=10 rowspan=2>$count</td>

          <td width=540 colspan=3 align=left>

					<font face=arial size=2>

					$author, $date, $title, $journal</font></td></tr><tr bgcolor=#cccccc><td width=500 align=left>";

          if($link1)

            {

            echo "<a href='./docs/$link1'>$link1</a>&nbsp;,";

            }

          if($link2)

            {

						echo "<a href='./docs/$link2'>$link2</a>&nbsp;,";

						}

					if($link3)

					  {

					  echo "<a href='./docs/$link3'>$link3</a>&nbsp;,";

					  }

					if($link4)

					  {

						echo "<a href='./docs/$link4'>$link4</a>&nbsp;,";

						}

				  if($link5)

				    {

						echo "<a href='./docs/$link5'>$link5</a>&nbsp;,";

						}

					if($link6)

					  {

						echo "<a href='./docs/$link6'>$link6</a>";

					  }

          if($user == "smpdocs")

						{          

          echo "</td><td width=20><a href=$PHP_SELF?action=delete_paper&user=$user&pass=$pass&paper_id=$paper_id>Delete</a></td>

          <td width=20><a href=$PHP_SELF?action=edit_paper_form&user=$user&pass=$pass&paper_id=$paper_id>Edit</a></td>

          </tr>";

            }

          }

        echo "</table>";

        }

      }

	  }

	

	function view_presentation()

	  {

		global $presentation_table, $user, $pass;

		$id = con($user, $pass);

    if($id)

      {

      $query = "SELECT * from $presentation_table order by topic ";

      $result = mysql_query($query);

      if($result)

        {

        while($query_data = mysql_fetch_array($result))

          {

          $presentation_id = $query_data["presentation_id"];

          $author = $query_data["author"];

          $date = $query_data["date"];

          $title = $query_data["title"];

          $proceedings = $query_data["proceedings"];

          $topic = $query_data["topic"];

          $link1 = $query_data["link1"];

          $link2 = $query_data["link2"];

          $link3 = $query_data["link3"];

          $link4 = $query_data["link4"];

          $link5 = $query_data["link5"];

          $link6 = $query_data["link6"];

          if($count == 0)

					  {

						echo "<table width=550 border><tr><th colspan=5 align=left bgcolor=eeeeee><font size=4>Presentations</font></th></tr>";

					  }

					$count++;

          if($topic != $oldtopic)

            {

						echo "<tr><td colspan=5 align=left bgcolor=dddddd><font size=4>Topic: $topic</font></td></tr>";

						$count = 1;

					  }

          $oldtopic = $topic;

          echo "

          <tr bgcolor=#cccccc>

          <td width=10 rowspan=2>$count</td>

          <td width=540 colspan=3 align=left>

					<font face=arial size=2>

					$author, $date, $title, $proceedings

					</font></td></tr><tr bgcolor=#cccccc><td width=500 align=left>";

          if($link1)

            {

            echo "<a href='./docs/$link1'>$link1</a>&nbsp;,";

            }

          if($link2)

            {

						echo "<a href='./docs/$link2'>$link2</a>&nbsp;,";

						}

					if($link3)

					  {

					  echo "<a href='./docs/$link3'>$link3</a>&nbsp;,";

					  }

					if($link4)

					  {

						echo "<a href='./docs/$link4'>$link4</a>&nbsp;,";

						}

				  if($link5)

				    {

						echo "<a href='./docs/$link5'>$link5</a>&nbsp;,";

						}

					if($link6)

					  {

						echo "<a href='./docs/$link6'>$link6</a>";

					  }

					if($user == "smpdocs")

					  {

          echo "</td><td width=20 align=right><a href=$PHP_SELF?action=delete_presentation&user=$user&pass=$pass&presentation_id=$presentation_id>Delete</a></td>

          <td width=20 align=right><a href=$PHP_SELF?action=edit_presentation_form&user=$user&pass=$pass&presentation_id=$presentation_id>Edit</a></td>

          </tr>";

            }

          }

        echo "</table>";

        }

      }	

	  }

  

  function view()

    {

    global $paper_table, $presentation_table, $user, $pass;

    if(empty($user))

		  {

		  echo "<script>

		          <!-- Begin

		            alert('Your username field is blank.\n');

		            history(-1);

		          //-->

		        </script> ";

		  }

		elseif(empty($pass))

	    {

	    echo "<script>

	            <!-- Begin

	              alert('Your password field is blank.\n');

	              history(-1);

	            //-->

	          </script> ";

      }

    elseif($user)

      {

		  if($pass)		

		    {

		    view_paper();

		    view_presentation();

			  }

		  }

    else

      {

      echo "<script>

              <!-- Begin

                alert('The connection to the books DB failed\n');

              //-->

            </script>  ";

      }

    }

    

  function webview()

    {

    global $paper_table, $presentation_table, $user, $pass, $default_user, $default_pass;

    if(empty($user))

		  {

		  $user = $default_user;

		  }

		if(empty($pass))

	    {

	    $pass = $default_pass;

      }

    

    if($user)

      {

		  if($pass)		

		    {

		    view_paper();

		    view_presentation();

			  }

		  }

    else

      {

      echo "<script>

              <!-- Begin

                alert('The connection to the books DB failed\n');

              //-->

            </script>  ";

      }	

    }

?>
