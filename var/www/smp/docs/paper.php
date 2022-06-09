<?
  function paper_form()
    {
    global $user, $pass;
    if(!$user)
      {
      echo " <script>alert('Your username field is blank.\n');history(-1);</script> ";
      }
    if(!$pass)
      {
      echo " <script>alert('Your password field is blank.\n');history(-1);</script> ";
      }
    $id = con($user, $pass);
    if($id)
      {
      echo "<form method=submit action=$PHP_SELF>
      <input type='hidden' name='action' value='insert_paper'>
      <input type='hidden' name='user' value='$user'>
      <input type='hidden' name='pass' value='$pass'>
      <table border>
      <tr><td colspan=2><b>Add Paper</b></td>
      <tr>
        <td width=100>Author:</td>
        <td width=100><input type='text' name='author'></td>
      </tr>
      <tr>
        <td width=100>Date:</td>
        <td width=100><input type='text' name='date'></td>
      </tr>
      <tr>
        <td width=100>Title:</td>
        <td width=100><input type='text' name='title'></td>
      </tr>
      <tr>
        <td width=100>Journal:</td>
        <td width=100><input type='text' name='journal'></td>
      </tr>
      <tr>
        <td width=100>Topic:</td>
        <td width=100><input type='text' name='topic'></td>
      </tr>
      <tr>
        <td width=100>File Name:</td>
        <td width=100><input type='text' name='link1'></td>
      </tr>
      <tr>
        <td width=100>File Name:</td>
        <td width=100><input type='text' name='link2'></td>
      </tr>
      <tr>
        <td width=100>File Name:</td>
        <td width=100><input type='text' name='link3'></td>
      </tr>
      <tr>
        <td width=100>File Name:</td>
        <td width=100><input type='text' name='link4'></td>
      </tr>
      <tr>
        <td width=100>File Name:</td>
        <td width=100><input type='text' name='link5'></td>
      </tr>
      <tr>
			  <td width=100>File Name:</td>
			  <td width=100><input type='text' name='link6'></td>
      </tr>
      <tr>
        <td colspan=2>
        <input type=submit>
        </td>
      </table>
      </form>";      
      }
    else
      {
      echo " <script>alert('Your username password combination do not match a valid database user\n');history(-1);</script> ";
      }
    }   
    
  function insert_paper()
	  {
	  global $paper_table, $user, $pass, $author, $date, $title, $journal, $topic, $link1;
	  global $link2, $PHP_SELF, $link3, $link4, $link5, $link6;
	  $id = con($user, $pass);
	  if($id)
		  {    
		  $query = "INSERT INTO $paper_table VALUES(NULL,'$author','$date','$title','$journal', '$topic', '$link1', '$link2', '$link3', '$link4', '$link5', '$link6') ";
		  $result = mysql_query($query);
		  if(!$result)
		    {
		    echo " <script>alert('The insertion failed');</script> ";
		 	 }
		  else
		    {
		    echo " <script>alert('The addition of the paper was successful!'); location = '$PHP_SELF?user=$user&pass=$pass&action=view';</script> ";					
		    }
		  }
	  else
		  {
		  echo " <script>alert('The conection to the books DB failed\n');</script> ";
		  }
    }
    
  function delete_paper()
    {
	  global $user, $pass, $paper_id, $default_db, $paper_table;  
		if(empty($paper_id))
		  {
		  echo " <script>alert('To delete a paper you need the paper ID.\n');</script> ";
		  }
		else
		  {
		  $id = con($user, $pass);
		  if($id)
		    {
		    $query = "DELETE FROM $paper_table where paper_id = '$paper_id' ";
		    $result = mysql_query($query);
		    if(!$result)
		      {
		      echo " <script>alert('The deleteion of the paper with $paper_id failed.\n');</script> ";
		      }
		    else
		      {
		      $num_rows = mysql_affected_rows($id);
		      if($num_rows != 1)
		        {
		        echo " <script>alert('There is no paper with an ID of $paper_id.\n');</script> ";
		        }
		      else
						{ 
						echo " <script>alert('The deletion of the paper with the ID of $paper_id was successful!'); location = '$PHP_SELF?user=$user&pass=$pass&action=view';</script> ";					
		  			}
		      }
		    }
		  else
		    {
		    echo " <script>alert('The connection to the $default_db DB failed\n');</script> ";
		    }
		  }
		}
		  
  function edit_paper_form()
		{
		global $user, $pass, $paper_id, $default_db, $paper_table;
		if(empty($paper_id))
		  {
		  echo " <script>alert('To edit a paper you need the paper ID.\n');</script> ";
		  }
		else
		  {
		  $id = con($user, $pass);
		  if($id)
		    {
		    $sql = " paper_id, author, date, title, journal, topic, link1, link2, link3, link4, link5, link6 ";
		    $query = "SELECT $sql FROM $paper_table where paper_id = '$paper_id' ";
		    $result = mysql_query($query);
		    if(!$result)
		      {
		      echo " <script>alert('The modifiction of the paper with $paper_id failed.\n');</script> ";
		      }
		    else
		      {
		      $num_rows = mysql_affected_rows($id);
		      if($num_rows != 1)
		        {
		        echo " <script>alert('There is no paper with an ID of $paper_id.\n');</script> ";
		        }
		      else
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
		          echo "<form method=submit action=$PHP_SELF>
		          <input type=hidden name=action value=edit_paper>
		          <input type=hidden name=user value=$user>
		          <input type=hidden name=pass value=$pass>
		            <table border width=550>
		              <tr>
		                <td align=left width=80 >ID:&nbsp;</td><td align=left width=420>
										  <input type='hidden' name='paper_id' value='$paper_id'>$paper_id
									  </td>
									</tr>
									<tr>
		                <td align=left width=80 >Author:&nbsp;</td>
									  <td align=left width=420><input type='text' name='author' value=\"$author\" size=65></td>
		              </tr>
									<tr>
									  <td align=left width=80 >Date:&nbsp;</td>
									  <td align=left width=420><input type='text' name='date' value=\"$date\"></td>
		              </tr>
									<tr>
									  <td align=left width=80 >Title:&nbsp;</td>
									  <td align=left width=420><input type='text' name='title' value=\"$title\" size=65></td>
		              </tr>
									<tr>
									  <td align=left width=80 >Journal:&nbsp;</td>
									  <td align=left width=420><input type='text' name='journal' value=\"$journal\" size=65></td>
		              </tr>
									<tr>
									  <td align=left width=80 >Topic:&nbsp;</td>
									  <td align=left width=420><input type='text' name='topic' value=\"$topic\" size=65></td>
		              </tr>
									<tr>
		                <td align=left width=80 >File Name:&nbsp;</td>
									  <td align=left width=420><input type='text' name='link1' value=\"$link1\" size=65></td>
		              </tr>
									<tr>
									  <td align=left width=80 >File Name:&nbsp;</td>
									  <td align=left width=420><input type='text' name='link2' value=\"$link2\" size=65></td>
		              </tr>
									<tr>
								    <td align=left width=80 >File Name:&nbsp;</td>
									  <td align=left width=420><input type='text' name='link3' value=\"$link3\" size=65></td>
		              </tr>
									<tr>
									  <td align=left width=80 >File Name:&nbsp;</td>
									  <td align=left width=420><input type='text' name='link4' value=\"$link4\" size=65></td>
		              </tr>
									<tr>
									  <td align=left width=80 >File Name:&nbsp;</td>
								  	<td align=left width=420><input type='text' name='link5' value=\"$link5\" size=65></td>
		              </tr>
									<tr>
								  	<td align=left width=80 >File Name:&nbsp;</td>
									  <td align=left width=420><input type='text' name='link6' value=\"$link6\" size=65></td>
		              </tr>
		            </table>
		          <input type='submit'> 
		          </form>";
		          }
		        }
		      }
		    }
		  else
		    {
		    echo " <script>alert('The connection to the $default_db DB failed\n');</script> // -->";
		    }
		  }
		}
		  
  function edit_paper()
		{
		global $paper_table, $default_db, $user, $pass, $paper_id, $author, $date, $title, $journal, $topic, $link1, $link2, $link3, $link4, $link5, $link6;
		$id = con($user, $pass);
		if($id)
		  {
		  $sql = " author='$author', date='$date', title='$title', journal='$journal', topic='$topic', link1='$link1', link2='$link2', link3='$link3', link4='$link4', link5='$link5', link6='$link6' ";
		  $query = "UPDATE $paper_table SET $sql WHERE paper_id = '$paper_id' ";
		  $result = mysql_query($query);
		  if(!$result)
		    {	
		    echo " <script>alert('The modification of the paper with an ID of $paper_id failed.\n');history(-1);</script> ";
		    }
		  else
		    {	
		    $num_rows = mysql_affected_rows($id);
		    if($num_rows == 0)
		      {
				  echo " <script> alert('Nothing Changed!'); location='$PHP_SELF?user=$user&pass=$pass&action=view'; </script> ";
				  }
				else
				  {
				  echo " <script>alert('The update of the paper with the ID of $paper_id was succesfull!'); location='$PHP_SELF?user=$user&pass=$pass&action=view';</script> ";					
  			  }
  			}
		  }
		else
		  {
		  echo " <script>alert('The connection to the $default_db DB failed\n');</script> ";
		  }
    }
?>
