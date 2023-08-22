-rw-r--r-- 1 dhall users  7632 2010-09-01 11:44 get_ca.cpp
-rw-r--r-- 1 dhall users  7372 2010-08-31 17:22 get_ca_deh.cpp
-rwxr-xr-x 1 dhall users 40295 2010-09-01 11:44 run_ca
-rwxr-xr-x 1 dhall users 40346 2010-08-31 17:22 run_ca_deh

dhall@ecoclim:~/ravel/CAcode> cat get_ca.cpp
// get_ca_dem.cpp
// Author:  Mary Ellen Miller; mmaryellen@gmail.com

// This program is used to retrieve DEM data in California for
// the Dry Ravel program.
// Inputs are two pairs of coordinates in decimal degrees these are
// converted to UTM coordinates and used to retrieve the DEM.

// inputfile is passed in with following data:
// latitude1
// longitude1
// latitude2
// longitude2
// path//filename_of_output_DEM
// path_to_ascii_DEM_files of California

// Include the header file
// headerfile.h include the namespace and files used in program
// headerfile.h also include the definition of constant
#include "headerfile.h"

// coord.h declare the class coord
// coord.cpp define the class coord
#include "coord.h"

// the main program begins
int main(int argc, char *argv[])
{
   string boxfile;   //Variable for DEM file name
   string filename;  //Path to byte searchable DEM
   double area_limit=1.2; //in sqkm  Controls area limitation
   double area_toosmall=0.0025;
// input coordinates in decimal degrees
   long double dd_latitude1=1.000000;  //  34.618102; //  34.242640;
   long double dd_longitude1=1.000000; //-119.434273; //-117.611900;
   long double dd_latitude2=1.005000;  //  34.621681; //  34.244640;
   long double dd_longitude2=1.005000; //-119.429660; //-117.6100;
   char *paramfilename=new char[80];
   char *outfilename=new char[80];     // DEH
   char *demfilename=new char[80];
   char *stringvar=new char(12);

   paramfilename=argv[1];  //pass in parameter file name
   outfilename=argv[2];    //pass in output file name DEH
   ofstream output(outfilename, ios::out);      // open for writing STDOUT DEH
   if (!output) { return 1; };   // DEH
   ifstream paraminput(paramfilename, ios::in); // open for reading

   //   input parameters from the coordinate input file
   //   detect if file not found  ** DEH
   if (!paraminput) { output << "ERR: Parameter input file '" << paramfilename << "' not found." << endl; return 1; }

        paraminput >> dd_latitude1 >> dd_longitude1 >> dd_latitude2 >> dd_longitude2
                           >> demfilename >> filename;
        output << dd_latitude1 << "\n";
        //      close the file which includes the input parameters
        paraminput.close();

        //Rough location check if lat\longs are possibly in California
        if ((dd_latitude1 < 32.282) || (dd_latitude2 < 32.282) || (dd_latitude1 > 42.131) || (dd_latitude2 > 42.131))
        {
           output << "ERR: Coordinates not in California\n";
           return 0;
        }
        if((dd_longitude1 < -124.556) || (dd_longitude2 < -124.556) || (dd_longitude1 > -113.956) || (dd_longitude2 > -113.956))
        {
           output << "ERR: Coordinates not in California\n";
           return 0;
        }
   //variables for ascii file
   int NumberofRow;
   int NumberofColumn;
   double Size=10;                      //define the size of each cell
   long double Xllcorner=0.0;           //lower left longitude coordinate
   long double Yllcorner=0.0;           //lower left latitude coordinate
   long double New_Xllcorner=0.0;       //lower left longitude coordinate
   long double New_Yllcorner=0.0;       //lower left latitude coordinate
   int Nodata=-32768;

   double area=0;
   long double x1=1.0000000;  //Eastings
   long double y1=1.0000000;  //Northings
   long double x2=1.0000000;  //Eastings
   long double y2=1.0000000;  //Northings
   int z1=0;
   int z2=0;

   //Datum 1 is NAD83/WGS84 - other datums not currently supported, but possible.
   int datum=1;

   // create new coordinate coord object
   coord *pcoord1=new coord(dd_latitude1,dd_longitude1);
   coord *pcoord2=new coord(dd_latitude2,dd_longitude2);

// call the function transform to calculate UTM coordinates
   pcoord1->transform(datum);
   pcoord2->transform(datum);

// Retrieve transformed coordinates
   x1=pcoord1->getx();
   y1=pcoord1->gety();
   z1=pcoord1->getzone();
   x2=pcoord2->getx();
   y2=pcoord2->gety();
   z2=pcoord2->getzone();

   if (z1 != z2)
   {
      if ((z1 == 10) && (z2 == 11))
          {
            z2 = 10;
            pcoord2->setzone(z2);
            pcoord2->transform(datum);
            x2=pcoord2->getx();
            y2=pcoord2->gety();
            z2=pcoord2->getzone();
          }
          else if ((z1 == 11) && (z2 == 10))
          {
            z1 = 10;
            pcoord1->setzone(z1);
            pcoord1->transform(datum);
            x1=pcoord1->getx();
            y1=pcoord1->gety();
            z1=pcoord1->getzone();
          }
   }

   long double minx=min(x1, x2);
   long double miny=min(y1, y2);
   long double maxx=max(x1, x2);
   long double maxy=max(y1, y2);

   //check to see if size limitation met
   area=(fabs(x1-x2)/1000)*(fabs(y1-y2)/1000);
   if (area > area_limit)
   {
           output << "ERR: Selected area is larger than " << area_limit << " square km\n";
           return 0;
   }
   if (area < area_toosmall)
   {
           output << "ERR: Selected area is smaller than " << area_toosmall << " square km";
           return 0;
   }

   //Go get data file
   else
   {
           pcoord1->getbox(minx,miny,z1,maxx,maxy,z2);
           boxfile=pcoord1->namebox();  //retrieve name of DEM file
           filename.append(boxfile);
           output << "Filename " << filename << "\n";
   }
// Check to see if data file retrieved
   if (strcmp(boxfile.c_str(),"no_box")==0)
   {
           output << "ERR: Coordinates not in California\n";
           return 0;
   }

//  Open data file and retrieve needed DEM data for dry ravel model
//      Open the file containing the elevation information and read in header

    ifstream pointinput(filename.c_str(), ios::in);
    // check for file not found ** DEH
    if (!pointinput) { output << "ERR: Point input file not found\n"; return 0; }
        pointinput >> stringvar >> NumberofColumn >> stringvar >> NumberofRow >>
                stringvar >> Xllcorner >> stringvar >> Yllcorner >> stringvar >>
                Size >> stringvar >> Nodata;
        // How report if FILE NOT FOUND?  ** DEH
        //cout<<"new position:"<<pointinput.tellg();
        int New_col=int(ceil((maxx-minx)/Size));
        int New_row=int(ceil((maxy-miny)/Size));
//      declare a pointer "nodeelevation" which will point to an array
//      storing the retrieved elevation data
        double **elevation = new double * [New_row+1];
        for (int i = 0; i < New_row+1; i++)
                elevation[i] = new double [New_col+1];

        //  convert UTM coordinates into byte location
        int start_x=int(floor((minx-Xllcorner)/Size));
        int start_y=int(floor((Yllcorner+100000-maxy)/Size));

        //      move into position to read data.
        pointinput.seekg((((start_y)*NumberofColumn+start_x)*11)+(2*(start_y+1)),ios::cur);
        //cout<<"new position:"<<pointinput.tellg();

        //      input the elevation into smaller grid.
        for(int i=0;i<New_row;i++) // MM 7/23/09 Remove + 1
        {
                for(int j=0;j<New_col;j++) // MM 7/23/09 Remove + 1
                {
//                elevation[i][j]=bigelevation[i+start_y][j+start_x];
                  pointinput >> elevation[i][j];
                }
                //skip undesired cells to get next line.
            pointinput.seekg((NumberofColumn-New_col)*11+2,ios::cur);
            //cout<<"new position:"<<pointinput.tellg();
        }
    pointinput.close();

        New_Xllcorner=Xllcorner+start_x*Size;
        New_Yllcorner=Yllcorner+100000-((start_y+New_row)*Size);
        // open an output file for dem data
        output << "UTM zone is: " << z1 << "\n";
        ofstream demgrd(demfilename, ios::out);
        demgrd << "NCOLS " << New_col << "\n";
        demgrd << "NROWS " << New_row << "\n";
        demgrd << "XLLCORNER " << setprecision(8) << New_Xllcorner << "\n";
        demgrd << "YLLCORNER " << setprecision(8) << New_Yllcorner << "\n";
        demgrd << "CELLSIZE " << Size << "\n";
        demgrd << "NODATA_VALUE " << Nodata << "\n";
        for(int i=0;i<New_row;i++) // MM 7/23/09 Remove + 1
        {
                for(int j=0;j<New_col;j++) // MM 7/23/09 Remove + 1
                {
                        demgrd << elevation[i][j] << " ";
                }
                demgrd << endl;
        }
   demgrd.close();
   return 0;
}

