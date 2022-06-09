<?
  function presentation_form()
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
		  <input type='hidden' name='action' value='insert_presentation'>
		  <input type='hidden' name='user' value='$user'>
		  <input type='hidden' name='pass' value='$pass'>
		    <table border>
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
		        <td width=100>Proceedings:</td>
		        <td width=100><input type='text' name='proceedings'></td>
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
   
  function insert_presentation()
    {
		global $presentation_table, $user, $pass, $author, $date, $title, $proceedings, $topic, $link1;
		global $link2, $PHP_SELF, $link3, $link4, $link5, $link6;
		$id = con($user, $pass);
		if($id)
		  {    
		  $query = "INSERT INTO $presentation_table VALUES(NULL,'$author','$date','$title','$proceedings', '$topic', '$link1', '$link2', '$link3', '$link4', '$link5', '$link6') ";
		  $result = mysql_query($query);
		  if(!$result)
		    {
		    echo " <script>alert('The insertion failed');</script> ";
				}
		  else
		    {
		    echo " <script>alert('The addition of the presentation was successful!'); location = '$PHP_SELF?user=$user&pass=$pass&action=view';</script> ";					
		    }
		  }
		else
		  {
		  echo " <script>alert('The conection to the books DB failed\n');</script> ";
		  }
    }  
  
  function delete_presentation()
	    {
		  global $user, $pass, $presentation_id, $default_db, $presentation_table;  
			if(empty($presentation_id))
			  {
			  echo " <script>alert('To delete a presentation you need the presentation ID.\n');</script> ";
			  }
			else
			  {
			  $id = con($user, $pass);
			  if($id)
			    {
			    $query = "DELETE FROM $presentation_table where presentation_id = '$presentation_id' ";
			    $result = mysql_query($query);
			    if(!$result)
			      {
			      echo " <script>alert('The deleteion of the presentation with $presentation_id failed.\n');</script> ";
			      }
			    else
			      {
			      $num_rows = mysql_affected_rows($id);
			      if($num_rows != 1)
			        {
			        echo " <script>
			                 alert('There is no presentation with an ID of $presentation_id.\n');
			               </script> ";
			        }
			      else
							{ 
							echo " <script>
							         alert('The deletion of the presentation with the ID of $presentation_id was successful!');
							         location = '$PHP_SELF?user=$user&pass=$pass&action=view';
							       </script> ";					
			  			}
			      }
			    }
			  else
			    {
			    echo " <script>alert('The connection to the $default_db DB failed\n');</script> ";
			    }
			  }
			}
			  
	  function edit_presentation_form()
			{
			global $user, $pass, $presentation_id, $default_db, $presentation_table;
			if(empty($presentation_id))
			  {
			  echo " <script>alert('To edit a presentation you need the presentation ID.\n');</script> ";
			  }
			else
			  {
			  $id = con($user, $pass);
			  if($id)
			    {
			    $sql = " presentation_id, author, date, title, proceedings, topic, link1, link2, link3, link4, link5, link6 ";
			    $query = "SELECT $sql FROM $presentation_table where presentation_id = '$presentation_id' ";
			    $result = mysql_query($query);
			    if(!$result)
			      {
			      echo " <script>alert('The modifiction of the presentation with $presentation_id failed.\n');</script> ";
			      }
			    else
			      {
			      $num_rows = mysql_affected_rows($id);
			      if($num_rows != 1)
			        {
			        echo " <script>alert('There is no presentation with an ID of $presentation_id.\n');</script> ";
			        }
			      else
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
			          echo "<form method=submit action=$PHP_SELF>
			          <input type=hidden name=action value=edit_presentation>
			          <input type=hidden name=user value=$user>
			          <input type=hidden name=pass value=$pass>
			          <table border width=550>
		              <tr>
		                <td align=left width=80 >ID:&nbsp;</td><td align=left width=420>
										  <input type='hidden' name='presentation_id' value='$presentation_id'>$presentation_id
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
									  <td align=left width=80 >Proceedings:&nbsp;</td>
									  <td align=left width=420><input type='text' name='proceedings' value=\"$proceedings\" size=65></td>
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
			  
	  function edit_presentation()
			{
			global $presentation_table, $default_db, $user, $pass, $presentation_id, $author, $date, $title, $proceedings, $topic, $link1, $link2, $link3, $link4, $link5, $link6;
			$id = con($user, $pass);
			if($id)
			  {
			  $sql = " author='$author', date='$date', title='$title', proceedings='$proceedings', topic='$topic', link1='$link1', link2='$link2', link3='$link3', link4='$link4', link5='$link5', link6='$link6' ";
			  $query = "UPDATE $presentation_table SET $sql WHERE presentation_id = '$presentation_id' ";
			  $result = mysql_query($query);
			  if(!$result)
			    {	
			    echo " <script>alert('The modification of the presentation with an ID of $presentation_id failed.\n');history(-1);</script> ";
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
					  echo " <script>alert('The update of the presentation with the ID of $presentation_id was succesfull!'); location='$PHP_SELF?user=$user&pass=$pass&action=view';</script> ";					
	  			  }
	  			}
			  }
			else
			  {
			  echo " <script>alert('The connection to the $default_db DB failed\n');</script> ";
			  }
    }
?>
