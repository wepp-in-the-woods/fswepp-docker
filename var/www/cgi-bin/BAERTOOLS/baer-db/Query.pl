# Query.pl
# Secondary "library" file containing code used both by our Web page generating
# code and by ad-hoc query code. By Conrad Albrecht (CMA) 2013.08.13.

use warnings;

################################# "#INCLUDES" ##################################

require CGI;
require Storable;
require XML::Simple;

###############################################################################
###############################################################################
# PACKAGE:  BaerProj.  -CMA 2013.07.25.

# Handles BaerProj objects (refs).  A BaerProj represents a BAER project
# from our database, but is higher-level than just representing a database table
# record; e.g. it holds this project's treatments, which come from another
# database table.
{

    package BaerProj;

    # A BaerProj object is an array of fields, with indices:
    #	0		Firename
    #	1		Forest
    #	2		FireStrt
    #	3		TotAcres
    #	4		Treatments (array ref of Treatment object refs, unsorted)
    #	5-17	Tagged properties (see tags hash)
    #	18		U.S. State
    #	19		Cost_of_No_Action (for ad hoc query 2013.08.06)
    #	20-21	Lat N & lon W (i.e. positive angle *W* of Greenwich), in
    #			radians.  -CMA 2013.08.23.
    #	22		RptTyp.  -CMA 2013.08.28.
    #	23		Handle.  This is actually this project's reverse index in the
    # 			TheProjs array, and is used so that the client can efficiently
    # 			request a specific project.  -CMA 2014.01.03.

    # Maps tagged property tag names to indices into our fields array.
    # Initialized in Init().
    my %c_Tags;

# BaerProj SUBS ################################################################

    sub AddTreatmentFromMdb {
        my ( $this, $rTmtFromMdb ) = @_;
        push( @{ $this->[4] }, Treatment::NewFromMdb($rTmtFromMdb) );
    }

    sub Firename { my ($this) = @_; return $this->[0]; }
    sub FireStrt { my ($this) = @_; return $this->[2]; }
    sub EroHazHh { my ($this) = @_; return $this->[5]; }
    sub EroHazLw { my ($this) = @_; return $this->[6]; }
    sub EroHazMd { my ($this) = @_; return $this->[7]; }
    sub FirIntHg { my ($this) = @_; return $this->[9]; }
    sub FirIntLw { my ($this) = @_; return $this->[10]; }
    sub FirIntMd { my ($this) = @_; return $this->[11]; }
    sub Forest   { my ($this) = @_; return $this->[1]; }

    # -CMA 2014.01.03.
    sub Handle { my ($this) = @_; return $this->[23]; }

###############################################################################
    # SUB:  BaerProj::Init.
    sub Init {

        # Because Perl has no compile-time init!
        %c_Tags = (
            "EroHazHh"          => 5,
            "EroHazLw"          => 6,
            "EroHazMd"          => 7,
            "EroPotnt"          => 8,
            "FirIntHg"          => 9,
            "FirIntLw"          => 10,
            "FirIntMd"          => 11,
            "WtrRplnt"          => 12,
            "LifeThrtDescr"     => 13,
            "PropThrtDescr"     => 14,
            "SoilProdThrtDescr" => 15,
            "T_x0026_ESpcDescr" => 16,
            "WtrQualThrtDescr"  => 17
        );
    }    # BaerProj::Init.  -CMA 2013.07.30.

###############################################################################
    # SUB:  BaerProj::Lat.
    # RETURN:  Latitude in radians.
    sub Lat {
        my ($this) = @_;
        return $this->[20];
    }    # BaerProj::Lat.  -CMA 2013.08.23.

###############################################################################
 # SUB:  BaerProj::Lon.
 # RETURN:  Longitude *west* in radians (positive values are west of Greenwich).
    sub Lon {
        my ($this) = @_;
        return $this->[21];
    }    # BaerProj::Lon.  -CMA 2013.08.23.

###############################################################################
    # SUB:  BaerProj::MatchesReqForest.
    sub MatchesReqForest {
        my ( $this, $ReqForest ) = @_;
        return $this->[1] eq $ReqForest;
    }    # BaerProj::MatchesReqForest.  -CMA 2013.08.06.

###############################################################################
    # SUB:  BaerProj::MatchesReqTmt.
    sub MatchesReqTmt {
        my ( $this, $ReqTmtCat ) = @_;
        my $bOther = ( "other" eq $ReqTmtCat );

        # For each of this BaerProj's treatments...
        for ( @{ $this->[4] } ) {

            # Get this treatment's type.
            my $TryTmtCat = Treatment::Type($_);

            if ( !length($TryTmtCat) ) {

            # If this treatment's category is not set and the category to match
            # is "other", then call it a match.  I figure the most likely reason
            # for the user to request "other" is if they want to cast a wide net
            # along with some real category, in which case they probably want
            # any uncategorized treatments too.
                if ($bOther) {
                    return 1;
                }
                else {
                    # Avoid error log warning from eq null below.
                    next;
                }
            }

            return 1 if $ReqTmtCat eq $TryTmtCat;

            # CMA replaced 2014.02.04.
            #		return 1 if $bOther && !length( $TryTmtCat );

        }

        return 0;
    }    # BaerProj::MatchesReqTmt.  -CMA 2014.02.04.

###############################################################################
    # SUB:  BaerProj::NewFromMdb.

    # NOTES:  The "Mdb" is not actually an .mdb file anymore, it's an .accdb
    # file, but this sub still processes the XML table exported from that DB.
    # -CMA 2013.08.23.
    sub NewFromMdb {
        my ($rProjFromXml) = @_;
        my @This;

        $This[0] = $rProjFromXml->{Firename};
        $This[0] =~ s/(\w+)/\u\L$1/g;          # Title-case it.
        $This[0] =~ s/Ii/II/g;                 # Uppercase Ii.  -CMA 2014.01.07.
        $This[0] =~ s/'S/'s/g;                 # Lowercase 'S.  -CMA 2014.01.07.
        $This[0] =~ s{\x{2019}S}{\x{2019}s}g;  # Unicode 'S.  -CMA 2014.01.07.
        $This[0] =~ s/Nf/NF/g;                 # Uppercase NF.  -CMA 2014.01.07.
        $This[0] =~ s/Mc(\w)/Mc\u$1/;    # Uppercase Scottish.  -CMA 2014.01.07.
        $This[1] = $rProjFromXml->{Forest};
        $This[1] =~ s/(\w+)/\u\L$1/g;    # Title-case it.

        # Truncating the fire start date to 10 chars because the time of day is
        # just clutter (they're all 0 anyway).
        $This[2] = substr( $rProjFromXml->{FireStrt}, 0, 10 );

        $This[3] = $rProjFromXml->{TotAcres};
        $This[4] = [];                          # Init w/ ref to empty array.

      # We store fields 5-17 by tag to support access by name.  This tag name is
      # the same as the XML element name.
        for ( keys(%c_Tags) ) {
            $This[ $c_Tags{$_} ] = $rProjFromXml->{$_};
        }

        $This[18] = $rProjFromXml->{State};

        # For ad hoc query 2013.08.06.
        $This[19] = $rProjFromXml->{Cost_of_No_Action};

        # -CMA 2013.08.23.
        $This[20] = $rProjFromXml->{Latitude};
        $This[20] *= 0.0174532925 if length( $This[20] );    # Deg to rad.
        $This[21] = $rProjFromXml->{Longitude};
        $This[21] *= 0.0174532925 if length( $This[21] );

        $This[22] = $rProjFromXml->{RptTyp};                 # -CMA 2013.08.28.

        return \@This;
    }    # BaerProj::NewFromMdb.  -CMA 2013.07.29.

###############################################################################
    # SUB:  BaerProj::NFSCost.
    sub NFSCost {
        my ($this) = @_;
        return BwdUtils::Total_fn( $this->[4], \&Treatment::NFSCost );
    }    # BaerProj::NFSCost.  -CMA 2013.08.02.

###############################################################################
    # SUB:  BaerProj::OwnsTreatmentFromMdb.

    # ACTION:  Determines whether this project is the project to which the given
    # treatment record from our DB belongs.
    sub OwnsTreatmentFromMdb {
        my ( $this, $rTmtFromMdb ) = @_;
        my $ProjFireNameUc = uc( $this->[0] );
        my $ProjForestUc   = uc( $this->[1] );
        my $bFireMatch     = ( $rTmtFromMdb->{firename} eq $ProjFireNameUc );

        return $bFireMatch && $rTmtFromMdb->{forest} eq $ProjForestUc;
    }    # BaerProj::OwnsTreatmentFromMdb.  -CMA 2013.07.29.

###############################################################################
    # SUB:  BaerProj::PropByTag.
    # NOTES:  Tested by Test140204_1544.  -CMA 2014.02.04.
    sub PropByTag {
        my ( $this, $Tag ) = @_;
        return $this->[ $c_Tags{$Tag} ];
    }    # BaerProj::PropByTag.  -CMA 2013.07.29.

###############################################################################
    # SUB:  BaerProj::RptTyp.
    sub RptTyp {
        my ($this) = @_;
        return $this->[22];
    }    # BaerProj::RptTyp.  -CMA 2013.08.28.

###############################################################################
    # SUB:  BaerProj::SetHandle.
    sub SetHandle {
        my ( $this, $Handle ) = @_;
        $this->[23] = $Handle;
    }    # BaerProj::SetHandle.  -CMA 2014.01.03.

###############################################################################
    # SUB:  BaerProj::State.
    sub State {
        my ($this) = @_;
        return $this->[18];
    }    # BaerProj::TotAcres.  -CMA 2013.08.05.

###############################################################################
    # SUB:  BaerProj::TotAcres.
    sub TotAcres {
        my ($this) = @_;
        return $this->[3];
    }    # BaerProj::TotAcres.  -CMA 2013.07.29.

###############################################################################
    # SUB:  BaerProj::TotalCost.
    sub TotalCost {
        my ($this) = @_;
        return BwdUtils::Total_fn( $this->[4], \&Treatment::TotalCost );
    }    # BaerProj::TotalCost.  -CMA 2013.08.02.

###############################################################################
    # SUB:  BaerProj::Treatments.
    sub Treatments {
        my ($this) = @_;
        return @{ $this->[4] };
    }    # BaerProj::Treatments.  -CMA 2013.07.29.

}    # End package BaerProj.

###############################################################################
###############################################################################
# PACKAGE:  BwdPageState.  -CMA 2013.08.03.

# Handles BwdPageState objects (refs).  A BwdPageState represents a set of URL
# params defining a (not necessarily *the* current) state of our index.pl page.
{

    package BwdPageState;

    # A BwdPageState object is an array of fields at designated indices.  The
    # "array" fields are *references* to arrays.  the indices are:

    # 0		Array of "forest" string params.

    # 1		Array of "tmt" string params.

    # 2-3	Start and end dates.  YYYY-MM-DD string params.  Filter-in projects
    #		between these dates, inclusive.  Empty string for either means don't
    #		filter at that end.

    # 4		"sort" string param.  Supported values are "cost", "dist", "name",
    #		"area", & "forest"; otherwise we use the default sort (fire start
    #		date).  -CMA 2014.01.13.

    # 5		page_start:  The requested starting # of the range of projects to
    #		show on this page; a 1-based index into the list of projects
    #		matching the current search filter.  This is as calculated, not
    #		necessarily as passed in a URL param, but may still be an invalid
    #		number for our list of projects.

    # 6		"view":  0 (means list view, default URL value) or 1 (means map
    #		view, "map" URL value).  -CMA 2014.01.24.

    # 7		"totals":  "true" or blank.  User preference.  Whether to report
    #		summed values over the requested projects (in a box before the info
    #		for indivual projects).

    # 8		"loc_type":  Which type of locations to list in the location select
    #		box in the Search form.  Valid values are "forest", "state", and
    #		"region".  Default is "forest".

    # 9		Array of "state" string params, for filtering by US State.  Valid
    #		Values are 'AR', 'AZ', 'CA', &c.

    # 10	Array of "rgn" string params, for filtering by FS region.

    # 11	"size": 0 (means shrunk, default URL value) or 1 (means expanded,
    #		"lg" URL value).  Determines whether projects are displayed as
    #		single lines in a table or large block summaries (except for
    #		exceptions, see field 12).  -CMA 2014.01.24.

    # 12	Array of "exp" params if size=small (even implicitly), or "shr"
    #		params if size=lg.  Param values are integers, offsets (0-based
    #		indices) into the list of projects showing on the current page.
    #		Causes the specified projects to be displayed expanded/shrunk.
    #		-CMA 2013.08.15.

    # 13	"unit": 0 (means English units, default URL value) or 1 (means
    #		metric, "met" URL value).  -CMA 2014.01.24.

    # 14	"pp":  # of results per page.  Default is 10.  -CMA 2013.08.19.

    # 15	"dN":  Degrees N, only used if sort=dist.  -CMA 2013.12.13.

    # 16	Array of "proj" params: integer project handles.  Specifies a set of
    #		projects to show summaries for, below the map in map view.
    #		-CMA 2014.01.06.

    # 17	Unused, available for reuse.  -CMA 2014.01.02.

    # 18	"dW":  Degrees W, only used if sort=dist.  -CMA 2013.12.13.

###############################################################################
    # SUB:  BwdPageState::ClearMapProjects.
    sub ClearMapProjects {
        my ($this) = @_;
        $this->[16] = [];
    }    # BwdPageState::ClearMapProjects.  -CMA 2014.01.06.

###############################################################################
    # SUB:  BwdPageState::Copy.
    sub Copy {
        my ($this) = @_;
        my @Ret;

        # Note that since we're using push(), these must be copied in order!

        # Deep-copy (1 level deep) fields 0 & 1 (array refs).
        push( @Ret, ( [ @{ $this->[0] } ], [ @{ $this->[1] } ] ) );

        push( @Ret, @{$this}[ 2 .. 8 ] );    # Simple scalar fields.

        # More array-ref fields (9 & 10).
        push( @Ret, ( [ @{ $this->[9] } ], [ @{ $this->[10] } ] ) );

        push( @Ret, $this->[11] );             # -CMA 2013.08.15.
        push( @Ret, [ @{ $this->[12] } ] );    # -CMA 2013.08.15.
        push( @Ret, @{$this}[ 13 .. 15 ] );    # -CMA 2014.01.06.
        push( @Ret, [ @{ $this->[16] } ] );    # -CMA 2013.01.06.
        push( @Ret, @{$this}[ 17 .. 18 ] );    # -CMA 2014.01.06.
        return \@Ret;
    }    # BwdPageState::Copy.  -CMA 2013.08.15.

###############################################################################
    # SUB:  BwdPageState::DegN.
    sub DegN {
        my ($this) = @_;
        return $this->[15];
    }    # BwdPageState::DegN.  -CMA 2013.08.23.

###############################################################################
    # SUB:  BwdPageState::DegW.
    sub DegW {
        my ($this) = @_;
        return $this->[18];
    }    # BwdPageState::DegW.  -CMA 2013.08.23.

###############################################################################
    # SUB:  BwdPageState::EndDate.
    sub EndDate {
        my ($this) = @_;
        return $this->[3];
    }    # BwdPageState::EndDate.  -CMA 2013.08.04.

###############################################################################
    # SUB:  BwdPageState::Filter.

  # PARAMS:  $raProjsParam is called "param" because it's a subroutine param, to
  # distinguish it from $raProjsRet.  Remember Perl scalars are passed by
  # reference, so we don't want to modify $raProjsParam!

    # NOTES:  Besides just filtering, also sorts if there's a request to.
    sub Filter {
        my ( $this, $raProjsParam ) = @_;

        # Filter by requested forests.
        my $raProjsRet =
          _rFilterOnList( $raProjsParam, $this->[0],
            \&BaerProj::MatchesReqForest );

        # _rFilterOnList() wants a fn which takes a BaerProj as param 0 and the
        # value to test as param 1.
        my $fnMatchesState = sub { BaerProj::State( $_[0] ) eq $_[1] };

        # Filter by requested states.  Note that our UI only supports requesting
        # forests, states, *xor* regions,  but it seems like simplest code, and
        # benign, to check for each one separately here.
        $raProjsRet =
          _rFilterOnList( $raProjsRet, $this->[9], $fnMatchesState );

       # If we stored the forest *logically* in the BaerProj (as a forest/region
       # index/value), rather than just its name, then we could avoid these
       # repeated expensive GetRegion() calls.  -CMA 2013.11.12.
        my $fnMatchesRgn = sub {
            BwdQuery::GetRegion( BaerProj::Forest( $_[0] ) ) == $_[1];
        };

        # Filter by requested regions.
        $raProjsRet = _rFilterOnList( $raProjsRet, $this->[10], $fnMatchesRgn );

        # Filter by requested treatments.
        $raProjsRet =
          _rFilterOnList( $raProjsRet, $this->[1], \&BaerProj::MatchesReqTmt );

    # Filter by start and end dates.  Arg 3 says to treat arg 2 as the start/end
    # of the date range.  -CMA 2013.08.16.
    # Tested by Test140206_1659.  -CMA 2014.02.06.
        $raProjsRet = _rFilterOnDate( $raProjsRet, $this->[2], 0 );
        $raProjsRet = _rFilterOnDate( $raProjsRet, $this->[3], 1 );

        return _rSort( $this, $raProjsRet );    # -CMA 2013.11.08.
    }    # BwdPageState::Filter.  -CMA 2013.08.01.

###############################################################################
    # SUB:  BwdPageState::Forests.
    sub Forests {
        my ($this) = @_;
        return @{ $this->[0] };
    }    # BwdPageState::Forests.  -CMA 2013.08.04.

###############################################################################
    # SUB:  BwdPageState::GetSortType.
    sub GetSortType {
        my ($this) = @_;
        return $this->[4];
    }    # BwdPageState::GetSortType.  -CMA 2013.11.12.

###############################################################################
    # SUB:  BwdPageState::HiddenParams.

 # NOTES:  These are the params that our Search form doesn't have controls for,
 # but which it needs to propagate, so they need to be added to the form as
 # hidden inputs.  This does not include params which the Search form doesn't
 # need to propagate, e.g. display-size exceptions, which become obsolete when a
 # new search is performed.
    sub HiddenParams {
        my ($this) = @_;
        my @Ret;

        push( @Ret, ( "totals",   "true" ) )     if $this->[7];
        push( @Ret, ( "loc_type", $this->[8] ) ) if $this->[8];
        push( @Ret, ( "size",     "lg" ) )  if $this->[11];   # -CMA 2014.01.24.
        push( @Ret, ( "unit",     "met" ) ) if $this->[13];   # -CMA 2014.01.24.
        return @Ret;
    }    # BwdPageState::HiddenParams.  -CMA 2013.08.04.

###############################################################################
    # SUB:  BwdPageState::IsMapView.
    sub IsMapView {
        my ($this) = @_;
        return $this->[6];
    }    # BwdPageState::IsMapView.  -CMA 2014.01.24.

###############################################################################
    # SUB:  BwdPageState::IsMetric.
    sub IsMetric {
        my ($this) = @_;
        return $this->[13];
    }    # BwdPageState::IsMetric.  -CMA 2014.01.24.

###############################################################################
    # SUB:  BwdPageState::LocType.

 # NOTES:  This returns the "logical" loc_type, which matches the param name for
 # values of the effective loc_type, but may not be the actual loc_type param
 # value from our URL.
    sub LocType {
        my ($this) = @_;
        if ( "state" eq $this->[8] || "rgn" eq $this->[8] ) {
            return $this->[8];
        }
        else {    # Default meaning for any other value.
            return "forest";
        }
    }    # BwdPageState::LocType.  -CMA 2013.08.05.

###############################################################################
    # SUB:  BwdPageState::NewExpandedRangeItr.
    sub NewExpandedRangeItr {
        my ( $this, $Start, $End ) = @_;
        return OnRangeItr::NewFromExceptions( $Start, $End, $this->[11],
            $this->[12] );
    }    # BwdPageState::NewExpandedRangeItr.  -CMA 2014.01.24.

###############################################################################
    # SUB:  BwdPageState::NewFromUrlParams.
    sub NewFromUrlParams {
        my @This;

        # Prune out any blank params, which our [All] options can send, but
        # which can make us select only the "" value instead of accepting all
        # values.
        $This[0] = [ grep { $_ } CGI::url_param("forest") ];
        $This[1] = [ grep { $_ } CGI::url_param("tmt") ];

        $This[2] = _StrParam("start_date");    # -CMA 2014.01.24.
        $This[3] = _StrParam("end_date");      # -CMA 2014.01.24.
        $This[4] = _StrParam("sort");          # -CMA 2014.01.24.

        # Normally this param is submitted by our "Next 10 Projects" button.
        $This[5] = CGI::url_param("page_start");

        # By default, start at #1.  -CMA 2014.01.24.
        $This[5] = 1 unless defined( $This[5] ) && $This[5] > 0;

        $This[6]  = _IsParamEq( "view", "map" );              # -CMA 2014.01.24.
        $This[7]  = CGI::url_param("totals");
        $This[8]  = _StrParam("loc_type");                    # -CMA 2014.01.24.
        $This[9]  = [ grep { $_ } CGI::url_param("state") ];
        $This[10] = [ grep { $_ } CGI::url_param("rgn") ];
        $This[11] = _IsParamEq( "size", "lg" );               # -CMA 2014.01.24.

      # Note that I'm accepting "false" values for this param, not just "true"
      # ones.  "0" is a legit value for this param (indicates the 1st project on
      # the page), and I don't expect blank values for this param from our UI.
      # -CMA 2013.11.26.
        $This[12] = [ CGI::url_param( _SizeExcParam( \@This ) ) ];

        $This[13] = _IsParamEq( "unit", "met" );    # -CMA 2014.01.24.
        $This[14] = CGI::url_param("pp");           # -CMA 2014.01.24.

        # Tested by Test140201_1340.  -CMA 2014.02.01.
        $This[15] = CGI::url_param("dN");           # -CMA 2014.01.24.
        if ( !defined( $This[15] ) || $This[15] !~ /^[-+]?\d+(\.\d+)?$/ ) {
            $This[15] = '';
        }

        # CMA replaced 2014.01.24.
        #	my @c_13_15 = ( "unit", "pp", "dN" );
        #	$This[ $_ ] = CGI::url_param( $c_13_15[ $_ - 13 ] ) for 13..15;

        # 0 is a legit project handle so I'm not pruning out blanks.
        # -CMA 2014.01.06.
        $This[16] = [ CGI::url_param("proj") ];

        $This[18] = CGI::url_param("dW");
        if ( !defined( $This[18] ) || $This[18] !~ /^[-+]?\d+(\.\d+)?$/ ) {
            $This[18] = '';
        }

        return \@This;
    }    # BwdPageState::NewFromUrlParams.  -CMA 2013.08.03.

###############################################################################
    # SUB:  BwdPageState::PageStart.
    sub PageStart {
        my ($this) = @_;
        return $this->[5];
    }    # BwdPageState::PageStart.  -CMA 2013.08.04.

###############################################################################
    # SUB:  BwdPageState::Params.
    # RETURN:  A list of alternating param names and values.
    sub Params {
        my ($this) = @_;
        my @Ret;

        push( @Ret, HiddenParams($this) );

      # The rest of these are params which the Search form has controls for (so
      # they aren't "hidden" in the Search form, or params which the Search form
      # doesn't need to propagate at all (because they become obsolete in a new
      # search).  -CMA 2014.01.06.

        # Array parameters.
        push( @Ret, ( "forest", $_ ) ) for @{ $this->[0] };
        push( @Ret, ( "tmt",    $_ ) ) for @{ $this->[1] };

        push( @Ret, ( "start_date", $this->[2] ) ) if $this->[2];
        push( @Ret, ( "end_date",   $this->[3] ) ) if $this->[3];
        push( @Ret, ( "sort",       $this->[4] ) ) if $this->[4];

    # Page start defaults to 1, so this param is only needed for greater values.
        push( @Ret, ( "page_start", $this->[5] ) ) if $this->[5] > 1;

        push( @Ret, ( "view",  "map" ) ) if $this->[6];    # -CMA 2014.01.24.
        push( @Ret, ( "state", $_ ) ) for @{ $this->[9] };
        push( @Ret, ( "rgn",   $_ ) ) for @{ $this->[10] };

        # -CMA 2013.08.15.
        push( @Ret, ( _SizeExcParam($this), $_ ) ) for @{ $this->[12] };

        if ( $this->[14] && $this->[14] != 10 ) {          # -CMA 2013.08.19.
            push( @Ret, ( "pp", $this->[14] ) );
        }

        push( @Ret, ( "dN",   $this->[15] ) ) if $this->[15];
        push( @Ret, ( "proj", $_ ) ) for @{ $this->[16] };    # -CMA 2014.01.06.
        push( @Ret, ( "dW",   $this->[18] ) ) if $this->[18];
        return @Ret;
    }    # BwdPageState::Params.  -CMA 2013.08.04.

###############################################################################
    # SUB:  BwdPageState::PerPage.
    sub PerPage {
        my ($this) = @_;
        return $this->[14] ? $this->[14] : 10;
    }    # BwdPageState::PerPage.  -CMA 2013.08.19.

###############################################################################
    # SUB:  BwdPageState::ProjectHandles.
    sub ProjectHandles {
        my ($this) = @_;
        return @{ $this->[16] };
    }    # BwdPageState::ProjectHandles.  -CMA 2014.01.06.

###############################################################################
    # SUB:  BwdPageState::Regions.
    sub Regions {
        my ($this) = @_;
        return @{ $this->[10] };
    }    # BwdPageState::Regions.  -CMA 2013.08.05.

###############################################################################
    # SUB:  BwdPageState::SetLocType.
    sub SetLocType {
        my ( $this, $LocType ) = @_;
        $this->[8] = $LocType;
    }    # BwdPageState::SetLocType.  -CMA 2013.08.05.

###############################################################################
    # SUB:  BwdPageState::SetOffsetSize.

  # ACTION:  Sets the view size (shrunk or expanded) of the project at the given
  # offset (from the top) in the page display.

    # NOTES:  Tested by Test140207_0935.  -CMA 2014.02.07.
    sub SetOffsetSize {
        my ( $this, $iOffset, $bExpand ) = @_;

       # What we store is *exceptions* to the current default view size, so
       # determine whether the requested size is an exception or not relative to
       # the current default.
        my $bAddExc = ( $this->[11] != $bExpand );    # -CMA 2014.01.24.

        # To set the project's view size as requested, either add or remove it
        # to/from the exceptions list, depending on the current default size.
        if ($bAddExc) {
            push( @{ $this->[12] }, $iOffset );
        }
        else {    # Remove any elements equaling $iOffset.
            $this->[12] = [ grep { $iOffset != $_ } @{ $this->[12] } ];
        }
    }    # BwdPageState::SetOffsetSize.  -CMA 2013.08.15.

###############################################################################
    # SUB:  BwdPageState::SetPageStart.
    sub SetPageStart {
        my ( $this, $PageStart ) = @_;
        $this->[5] = $PageStart;

      # Display size exceptions apply only to the current page, so when the page
      # changes, they should be cleared.  -CMA 2013.08.15.
        $this->[12] = [];
    }    # BwdPageState::SetPageStart.  -CMA 2013.08.04.

###############################################################################
    # SUB:  BwdPageState::SetShowTotals.
    sub SetShowTotals {
        my ( $this, $bShow ) = @_;
        $this->[7] = $bShow;
    }    # BwdPageState::SetShowTotals.  -CMA 2013.08.04.

###############################################################################
 # SUB:  BwdPageState::SetSize.
 # ACTION:  Sets the current default view size (shrunk or expanded) for reports.
    sub SetSize {
        my ( $this, $bLarge ) = @_;
        $this->[11] = $bLarge;    # -CMA 2014.01.24.

        # When the overall display size is reset, presumably any existing size
        # exceptions are obsolete.
        $this->[12] = [];
    }    # BwdPageState::SetSize.  -CMA 2013.08.15.

###############################################################################
    # SUB:  BwdPageState::SetSortType.
    sub SetSortType {
        my ( $this, $SortType ) = @_;
        $this->[4] = $SortType;

      # A new sort will make the current page start meaningless, so it should be
      # cleared.
        SetPageStart( $this, 1 );
    }    # BwdPageState::SetSortype.  -CMA 2014.01.13.

###############################################################################
    # SUB:  BwdPageState::ShouldShowTotals.
    sub ShouldShowTotals {
        my ($this) = @_;
        return $this->[7];
    }    # BwdPageState::ShouldShowTotals.  -CMA 2013.08.04.

###############################################################################
    # SUB:  BwdPageState::StartDate.
    sub StartDate {
        my ($this) = @_;
        return $this->[2];
    }    # BwdPageState::StartDate.  -CMA 2013.08.04.

###############################################################################
    # SUB:  BwdPageState::States.
    sub States {
        my ($this) = @_;
        return @{ $this->[9] };
    }    # BwdPageState::States.  -CMA 2013.08.05.

###############################################################################
    # SUB:  BwdPageState::ToggleUnits.
    sub ToggleUnits {
        my ($this) = @_;
        $this->[13] = !$this->[13];
    }    # BwdPageState::ToggleUnits.  -CMA 2014.01.24.

###############################################################################
    # SUB:  BwdPageState::Treatments.
    sub Treatments {
        my ($this) = @_;
        return @{ $this->[1] };
    }    # BwdPageState::Treatments.  -CMA 2013.08.04.

###############################################################################
    # SUB:  BwdPageState::_rFilterOnDate.
    sub _rFilterOnDate {
        my ( $raProjs, $DateParam, $bEnd ) = @_;
        my @Parts = split /-/, $DateParam;

        return $raProjs unless @Parts;    # If there was no year part.

        # Fill in missing month and day parts.
        $Parts[1] = $bEnd ? "12" : "01" if @Parts < 2;
        $Parts[2] = $bEnd ? "31" : "01" if @Parts < 3;

       # If the user-submitted filter date has 3+ letters in the month position,
       # then translate the month to a number so we can compare it.
        if ( $Parts[1] =~ /^[a-zA-Z][a-zA-Z][a-zA-Z]/ ) {
            my $Mo    = uc( substr( $Parts[1], 0, 3 ) );
            my $MoIdx = -1;

            for ( 0 .. $#BwdQuery::c_Mos ) {
                $MoIdx = $_ if $BwdQuery::c_Mos[$_] eq $Mo;
            }

            $Parts[1] = $MoIdx + 1;
        }

        # Expand 1-digit month or date to 2 digits.
        $Parts[1] = "0" . $Parts[1] if length( $Parts[1] ) < 2;
        $Parts[2] = "0" . $Parts[2] if length( $Parts[2] ) < 2;

        my $FiltDate = $Parts[0] . "-" . $Parts[1] . "-" . $Parts[2];
        my @FiltProjs;

        for (@$raProjs) {
            my $ProjDate = BaerProj::FireStrt($_);
            my $bReject =
              $bEnd ? $ProjDate gt $FiltDate : $ProjDate lt $FiltDate;

            push( @FiltProjs, $_ ) unless $bReject;
        }

        return \@FiltProjs;
    }    # BwdPageState::_rFilterOnDate.  -CMA 2013.11.18.

###############################################################################
    # SUB:  BwdPageState::_rFilterOnList.

    # PARAMS:
    #	$raFilter:  A list of param values from a multi-value select element.
    #	$rfnTest:  The function which tests a project with a value from the list.
    sub _rFilterOnList {
        my ( $raProjs, $raFilter, $rfnTest ) = @_;

        # To filter on the list, first, there must *be* a list...
        return $raProjs unless @$raFilter;

        my @FiltProjs;

        for my $rProj (@$raProjs) {
            for (@$raFilter) {
                if ( $rfnTest->( $rProj, $_ ) ) {
                    push( @FiltProjs, $rProj );

                    # In this case we have included this project, so skip
                    # remaining requested forests for this project and skip to
                    # the next project.  Besides efficiency, in the odd cases of
                    # requesting both regions and forests or requesting the same
                    # forest twice (possible in the URL), we don't want dups.
                    last;
                }
            }
        }

        return \@FiltProjs;
    }    # BwdPageState::_rFilterOnList.  -CMA 2013.08.01.

###############################################################################
    # SUB:  BwdPageState::_IsParamEq.
    sub _IsParamEq {
        my ( $ParamName, $CmpVal ) = @_;

    # Without "scalar", url_param() can return an empty list, which Perl concats
    # with $CmpVal as Eq()'s argument list!
        return BwdUtils::Eq( scalar CGI::url_param($ParamName), $CmpVal );
    }    # BwdPageState::_IsParamEq.  -CMA 2014.01.24.

###############################################################################
    # SUB:  BwdPageState::_SizeExcParam.

  # ACTION:  Determines which param name, shr or exp, is currently used for
  # view-size exceptions.  If we're in the default shrunken-size state, then
  # exceptions are "exp"; otherwise, we're in the "lg" default-expanded state, &
  # exceptions are "shr".
    sub _SizeExcParam {
        my ($this) = @_;
        return $this->[11] ? "shr" : "exp";
    }    # BwdPageState::_SizeExcParam.  -CMA 2014.01.24.

###############################################################################
    # SUB:  BwdPageState::_rSort.
    sub _rSort {
        my ( $this, $raProjs ) = @_;
        if ( IsMapView($this) ) {

            # Sorting not needed in map view.  -CMA 2013.12.30.
            return $raProjs;
        }
        elsif ( "cost" eq $this->[4] ) {
            my $fnCostliest = sub {
                return BaerProj::TotalCost($b) <=> BaerProj::TotalCost($a);
            };

            return [ sort $fnCostliest @$raProjs ];
        }
        elsif ( "dist" eq $this->[4] ) {    # -CMA 2013.08.23.
            return _rSortByDist( $this, $raProjs );
        }
        elsif ( "name" eq $this->[4] ) {
            my $fnAlph = sub {
                my $NameA = uc( BaerProj::Firename($a) );

                return $NameA cmp uc( BaerProj::Firename($b) );
            };

            return [ sort $fnAlph @$raProjs ];
        }
        elsif ( "area" eq $this->[4] ) {    # -CMA 2014.01.13.
            my $fnBiggest = sub {
                my $AcresA = BaerProj::TotAcres($a);
                my $AcresB = BaerProj::TotAcres($b);

                # Avoid error log warnings from <=> null.  -CMA 2014.02.05.
                $AcresA = 0 unless $AcresA;
                $AcresB = 0 unless $AcresB;

                # Tested by Test140205_0821.  -CMA 2014.02.05.
                return $AcresB <=> $AcresA;
            };

            return [ sort $fnBiggest @$raProjs ];
        }
        elsif ( "forest" eq $this->[4] ) {
            my $fnAlph = sub {
                my $ForestA = uc( BaerProj::Forest($a) );

                return $ForestA cmp uc( BaerProj::Forest($b) );
            };

            return [ sort $fnAlph @$raProjs ];
        }
        else {
            return $raProjs;
        }
    }    # BwdPageState::_rSort.  -CMA 2013.11.08.

###############################################################################
    # SUB:  BwdPageState::_rSortByDist.
    sub _rSortByDist {
        my ( $this, $raProjs ) = @_;
        my $RadN = $this->[15] * 0.0174532925;
        my $RadW = $this->[18] * 0.0174532925;

      # The user can easily enter negative values (especially lons) by "mistake"
      # in the UI, since that's a convention for deg W.  -CMA 2013.11.18.
        $RadN *= -1 if $RadN < 0;
        $RadW *= -1 if $RadW < 0;

     # Note that this sub accesses local vars, a weird Perl thing which I guess
     # means that this sub def and the sort() call must be in the scope of these
     # vars?
        my $fnNearest = sub {
            my $LatA   = BaerProj::Lat($a);
            my $LonA   = BaerProj::Lon($a);
            my $LatB   = BaerProj::Lat($b);
            my $LonB   = BaerProj::Lon($b);
            my $bBGood = length($LatB) && length($LonB);

            return $bBGood ? 1 : 0 unless length($LatA) && length($LonA);
            return -1              unless $bBGood;

            my $LatDistA = $LatA - $RadN;
            my $LonDistA = ( $LonA - $RadW ) * cos( ( $LatA + $RadN ) / 2.0 );

            # This is the less accurate, but fast, "equirectangular
            # approximation" for great-circle distance.
            my $Dist2A = $LatDistA * $LatDistA + $LonDistA * $LonDistA;

            my $LatDistB = $LatB - $RadN;
            my $LonDistB = ( $LonB - $RadW ) * cos( ( $LatB + $RadN ) / 2.0 );
            my $Dist2B   = $LatDistB * $LatDistB + $LonDistB * $LonDistB;

            # Of course I can just compare *squared* distances, no need to take
            # the root.
            return $Dist2A <=> $Dist2B;
        };

        return [ sort $fnNearest @$raProjs ];
    }    # BwdPageState::_rSortByDist.  -CMA 2014.02.03.

###############################################################################
    # SUB:  BwdPageState::_StrParam.
    sub _StrParam {
        my ($ParamName) = @_;
        my $Val = CGI::url_param($ParamName);

        return defined($Val) ? $Val : "";    # Avoid null warnings.
    }    # BwdPageState::_StrParam.  -CMA 2014.01.24.

}    # End package BwdPageState.

###############################################################################
###############################################################################
# PACKAGE:  BwdQuery.  -CMA 2013.08.13.

# Package for services provided by this file which don't go in any other
# particular package.
{

    package BwdQuery;

###############################################################################
    # DATA:  BwdQuery::@c_Forests.

    # Our forests & their regions, from the EBAER DB RegionsForests table.
    # Since this table is small and I expect it to change rarely, I think it's
    # most expedient to just hard-code it here.  -CMA 2013.06.18.
    our @c_Forests = (
        [ "Allegheny",                   9 ],
        [ "Angeles",                     5 ],
        [ "Angelina",                    8 ],
        [ "Apache-Sitgreaves",           3 ],
        [ "Apalachicola",                8 ],
        [ "Arapaho-Roosevelt",           2 ],
        [ "Ashley",                      4 ],
        [ "Beaverhead-Deerlodge",        1 ],
        [ "Bienville",                   8 ],
        [ "Bighorn",                     2 ],
        [ "Bitterroot",                  1 ],
        [ "Black Hills",                 2 ],
        [ "Boise",                       4 ],
        [ "Bridger-Teton",               4 ],
        [ "Caribou",                     4 ],
        [ "Caribou-Targhee",             10 ],
        [ "Carson",                      3 ],
        [ "Chattahoochee-Oconee",        8 ],
        [ "Chequamegon-Nicolet",         10 ],
        [ "Cherokee",                    8 ],
        [ "Chippewa",                    9 ],
        [ "Chugach",                     10 ],
        [ "Cibola",                      3 ],
        [ "Clearwater",                  1 ],
        [ "Cleveland",                   5 ],
        [ "Coconino",                    3 ],
        [ "Colville",                    6 ],
        [ "Conecuh",                     8 ],
        [ "Coronado",                    3 ],
        [ "Croatan",                     8 ],
        [ "Custer",                      1 ],
        [ "Dakota Prairie Grasslands",   1 ],
        [ "Daniel Boone",                8 ],
        [ "Davy Crockett",               8 ],
        [ "De Soto",                     8 ],
        [ "Delta",                       8 ],
        [ "Deschutes",                   6 ],
        [ "Dixie",                       4 ],
        [ "El Yunque",                   8 ],
        [ "Eldorado",                    5 ],
        [ "Finger Lakes",                9 ],
        [ "Fishlake",                    4 ],
        [ "Flathead",                    1 ],
        [ "Francis Marion",              8 ],
        [ "Fremont",                     6 ],
        [ "Fremont-Winema",              6 ],
        [ "Gallatin",                    1 ],
        [ "George Washington",           8 ],
        [ "George Washington-Jefferson", 9 ],
        [ "Gifford Pinchot",             6 ],
        [ "Gila",                        3 ],
        [ "Grand Mesa-Uncompahgre",      2 ],
        [ "Green Mountain",              9 ],
        [ "Gunnison",                    2 ],
        [ "Helena",                      1 ],
        [ "Hiawatha",                    9 ],
        [ "Holly Springs",               8 ],
        [ "Homochitto",                  8 ],
        [ "Hoosier",                     9 ],
        [ "Humboldt-Toiyabe",            4 ],
        [ "Huron-Manistee",              9 ],
        [ "Idaho Panhandle",             1 ],
        [ "Inyo",                        5 ],
        [ "Kaibab",                      3 ],
        [ "Kisatchie",                   8 ],
        [ "Klamath",                     5 ],
        [ "Kootenai",                    1 ],
        [ "Lake Tahoe Basin Mu",         5 ],
        [ "Land Between The Lakes",      8 ],
        [ "Lassen",                      5 ],
        [ "Lewis And Clark",             1 ],
        [ "Lincoln",                     3 ],
        [ "Lolo",                        1 ],
        [ "Los Padres",                  5 ],
        [ "Malheur",                     6 ],
        [ "Manti-Lasal",                 4 ],
        [ "Mark Twain",                  9 ],
        [ "Medicine Bow-Routt",          2 ],
        [ "Mendocino",                   5 ],
        [ "Mississippi Nfs",             8 ],
        [ "Modoc",                       5 ],
        [ "Monongahela",                 8 ],
        [ "Mount Hood",                  6 ],
        [ "Mt Baker-Snoqualmie",         6 ],
        [ "Nantahala",                   8 ],
        [ "Nebraska",                    2 ],
        [ "Nez Perce",                   1 ],
        [ "Ocala",                       8 ],
        [ "Ochoco",                      6 ],
        [ "Okanogan",                    6 ],
        [ "Okanogan-Wenatchee",          6 ],
        [ "Olympic",                     6 ],
        [ "Osceola",                     8 ],
        [ "Ottawa",                      9 ],
        [ "Ouachita",                    8 ],
        [ "Ozark-St Francis",            8 ],
        [ "Payette",                     4 ],
        [ "Pike",                        2 ],
        [ "Pike-San Isabel",             2 ],
        [ "Pisgah",                      8 ],
        [ "Plumas",                      5 ],
        [ "Prescott",                    3 ],
        [ "Region1",                     1 ],
        [ "Region2",                     2 ],
        [ "Region3",                     3 ],
        [ "Region4",                     4 ],
        [ "Region5",                     5 ],
        [ "Region6",                     6 ],
        [ "Rio Grande",                  2 ],
        [ "Rogue River",                 6 ],
        [ "Rogue River-Siskiyou",        6 ],
        [ "Roosevelt",                   2 ],
        [ "Sabine",                      8 ],
        [ "Salmon-Challis",              4 ],
        [ "Sam Houston",                 8 ],
        [ "Samuel R Mckelvie",           8 ],
        [ "San Bernardino",              5 ],
        [ "San Isabel",                  2 ],
        [ "San Juan",                    2 ],
        [ "San Juan-Rio Grande",         2 ],
        [ "Santa Fe",                    3 ],
        [ "Sawtooth",                    4 ],
        [ "Sequoia",                     5 ],
        [ "Shasta-Trinity",              5 ],
        [ "Shoshone",                    2 ],
        [ "Sierra",                      5 ],
        [ "Siskiyou",                    6 ],
        [ "Siuslaw",                     6 ],
        [ "Six Rivers",                  5 ],
        [ "Stanislaus",                  5 ],
        [ "Sumter",                      8 ],
        [ "Superior",                    9 ],
        [ "Tahoe",                       5 ],
        [ "Talladega",                   8 ],
        [ "Targhee",                     4 ],
        [ "Tombigbee",                   8 ],
        [ "Tongass",                     10 ],
        [ "Tonto",                       3 ],
        [ "Tuskegee",                    8 ],
        [ "Uinta",                       4 ],
        [ "Uinta-Wasatch-Cache",         4 ],
        [ "Umatilla",                    6 ],
        [ "Umpqua",                      6 ],
        [ "Uncompahgre",                 4 ],
        [ "Uwharrie",                    8 ],
        [ "Wallowa-Whitman",             6 ],
        [ "Wasatch-Cache",               4 ],
        [ "Wayne",                       9 ],
        [ "Wenatchee",                   6 ],
        [ "Westwide Info",               0 ],
        [ "White Mountain",              4 ],
        [ "White River",                 2 ],
        [ "Willamette",                  6 ],
        [ "William B Bankhead",          8 ],
        [ "Winema",                      6 ]
    );

    # The EBAER (Access) DB contains "REGIONX" entries here.  I've decided
    # that these entries need to remain in the DB RegionsForests table to be
    # used for projects for which we have a region but not a forest for some
    # reason.  But I don't want those entries here, because this list is
    # used to populate the list of forests that the user can select from.
    # Instead, I do special processing of projects with "REGIONX" forests
    # where necessary.  -CMA 2013.11.12.

###############################################################################
    # DATA:  BwdQuery::c_Mos.
    our @c_Mos = (
        "JAN", "FEB", "MAR", "APR", "MAY", "JUN",
        "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"
    );    # -CMA 2013.08.16.

###############################################################################
    # SUB:  BwdQuery::GetRegion.
    # PARAMS:  $Forest is a project record's Forest field.
    sub GetRegion {
        my ($Forest) = @_;

       # A binary search, or even a linear search that quit on success, would be
       # faster, since we know there's a max of 1 result.
        my @Hits = grep { $_->[0] eq $Forest } @c_Forests;

        return $Hits[0]->[1] if @Hits;

     # For our very few projects where we know the region but not the forest, we
     # should've stored "REGIONX" as the forest (title-cased on import into our
     # Perl code), so we can return the "X" as the region.  We currently have no
     # projects whose Forest record fails both the search above and the
     # /^Region./ test below, but if we get one, I want to avoid generating a
     # warning by calling substr() out of range.
     #
     # Tested by Test140128_0000.  -CMA 2014.01.29.
        return $Forest =~ /^Region./ ? substr( $Forest, 6 ) : 0;
    }    # BwdQuery::GetRegion.  -CMA 2013.11.12.

###############################################################################
    # SUB:  BwdQuery::GetRelink.

   # ACTION:  Generates an <a> element string linking back to this page with the
   # given page-state URL params and link text.
    sub GetRelink {
        my ( $rPageState, $LinkText ) = @_;
        my $Url = GetRelinkUrl($rPageState);

        return "<a href='$Url'>$LinkText</a>";
    }    # BwdQuery::GetRelink.  -CMA 2013.08.04.

###############################################################################
    # SUB:  BwdQuery::GetRelinkUrl.

   # ACTION:  Gets a URL linking back to this page with the given page-state URL
   # params.
    sub GetRelinkUrl {
        my ($rPageState) = @_;
        my @Params       = BwdPageState::Params($rPageState);
        my $Query        = "";

        for ( 0 .. @Params / 2 - 1 ) {

        # One example of where we need urlencoding:  forest names with spaces in
        # our forest= param.
            my $EncVal = BwdUtils::urlencode( $Params[ $_ * 2 + 1 ] );

            $Query .= $Params[ $_ * 2 ] . "=" . $EncVal . "&";
        }

        return "index.pl?$Query";
    }    # BwdQuery::GetRelinkUrl.  -CMA 2013.08.06.

###############################################################################
    # SUB:  BwdQuery::GetSortPhrase.

  # ACTION:  Generates a description of how the results are ordered, of the form
  # "ordered by ...".
    sub GetSortPhrase {
        my $rPageState = TheBwdPageState::GetC();
        my $SortPhrase;
        my $SortType = BwdPageState::GetSortType($rPageState);

        if ( "cost" eq $SortType ) {
            $SortPhrase = "highest cost";
        }
        elsif ( "dist" eq $SortType ) {
            my $Dms =
                "("
              . BwdPageState::DegN($rPageState)
              . "&deg; N, "
              . BwdPageState::DegW($rPageState)
              . "&deg; W)";

            $SortPhrase = "distance from $Dms";
        }
        elsif ( "name" eq $SortType ) {
            $SortPhrase = "fire name";
        }
        elsif ( "area" eq $SortType ) {
            $SortPhrase = "largest size";
        }
        elsif ( "forest" eq $SortType ) {
            $SortPhrase = "forest name";
        }
        else {
            $SortPhrase = "most recent fire date";
        }

        return "ordered by $SortPhrase";
    }    # BwdQuery::GetSortPhrase.  -CMA 2013.11.12.

###############################################################################
    # SUB:  BwdQuery::GetTotalsRelink.

    # ACTION:  Generates an <a> element string linking back to this page which
    # toggles the current "show totals" preference.
    sub GetTotalsRelink {
        my $rLinkPageState = TheBwdPageState::GetCopy();
        my $bShowTotals    = TheBwdPageState::ShouldShowTotals();

        BwdPageState::SetShowTotals( $rLinkPageState, !$bShowTotals );
        return GetRelink( $rLinkPageState,
            $bShowTotals ? "hide" : "show totals" );
    }    # BwdQuery::GetTotalsRelink.  -CMA 2013.08.04.

###############################################################################
    # SUB:  BwdQuery::GetUnitsRelink.

    # ACTION:  Generates an <a> element string linking back to this page which
    # toggles the current English/metric units preference.
    sub GetUnitsRelink {
        my $rMetricPageState = TheBwdPageState::GetCopy();
        my $bMetric          = BwdPageState::IsMetric($rMetricPageState);

        BwdPageState::ToggleUnits($rMetricPageState);

        my $UnitsCmd = $bMetric ? "English&nbsp;units" : "metric&nbsp;units";

        return GetRelink( $rMetricPageState, $UnitsCmd );
    }    # BwdQuery::GetUnitsRelink.  -CMA 2014.01.07.

}    # End package BwdQuery.

###############################################################################
###############################################################################
# PACKAGE:  BwdUtils.  -CMA 2013.08.13.

# General-purpose support code.  Not enough to put in its own file yet.
{

    package BwdUtils;

###############################################################################
    # SUB:  BwdUtils::commify.

  # NOTES:  Copied from perlfaq5.  I tried not commifying 4-digit numbers, but
  # then changed my mind because it actually seems pretty common to commify them
  # and they line up better in columns.
    sub commify {
        local $_ = shift;

        1 while s/^([-+]?\d+)(\d{3})/$1,$2/;
        return $_;
    }    # BwdUtils::commify.  -CMA 2013.06.25.

###############################################################################
    # SUB:  BwdUtils::Eq.
    # ACTION:  Our own "eq" which handles a 1st null param.

# NOTES:  Optimized for the case where we know the 2nd param is real, so we only
# check the 1st param for null.
    sub Eq {
        my ( $Unknown, $Known ) = @_;
        return defined($Unknown) ? $Unknown eq $Known : 0;
    }    # BwdUtils::Eq.  -CMA 2014.01.24.

###############################################################################
    # SUB:  BwdUtils::SortAlpha.
    sub SortAlpha {
        my ($ra) = @_;
        return sort { uc($a) cmp uc($b) } @$ra;
    }    # BwdUtils::SortAlpha.  -CMA 2014.01.16.

###############################################################################
    # SUB:  BwdUtils::Total_fn.
    sub Total_fn {
        my ( $ra, $rfnGetVal ) = @_;
        my $Tot = 0;

        for (@$ra) {
            my $Val = $rfnGetVal->($_);

            # The test avoids error log + null warnings.  -CMA 2014.02.04.
            $Tot += $Val if $Val;
        }

    # Rounding (to 0 places) because this sub is used to display numbers, but
    # the floating-point addition introduces spurious extra precision to the
    # limited-precision input numbers.  I might need a more sophisticated way to
    # determine output precision, but I don't yet know what that would be, and
    # this at least makes columns of numbers line up.
        return sprintf( "%.0f", $Tot );
    }    # BwdUtils::Total_fn.  -CMA 2013.08.02.

###############################################################################
    # SUB:  BwdUtils::urlencode.

   # NOTES:  Copied from a forum.  It looks like this will not handle a "+"
   # correctly (it will be changed to a space on decoding).  AFAIK we don't have
   # any +'s in the data that we're passing to this sub.
    sub urlencode {
        my ($s) = @_;
        $s =~ s/ /+/g;
        $s =~ s/([^A-Za-z0-9\+-])/sprintf("%%%02X", ord($1))/seg;
        return $s;
    }    # BwdUtils::urlencode.  -CMA 2013.07.31.

}    # End package BwdUtils.

###############################################################################
###############################################################################
# PACKAGE:  OnRangeItr.  -CMA 2013.08.14.

# Handles OnRangeItr objects (refs).  An OnRangeItr iterates through a sequence
# of contiguous alternating on/off subranges of an overall range of integers.
{

    package OnRangeItr;

    # An OnRangeItr object is an array, with indices:

    # 0		Start of overall range (and 1st subrange), set in ctor.

    # 1		Array (ref) of Booleans.  Indices are offsets into the overall
    #		range; values indicate whether than position is on or off.  The size
    #		of this array is the size of the overall range.  Set in ctor.
    #		Obviously this implementation would waste massive memory space for
    #		really large ranges, but we don't use this class for any of those.

    # 2		Current offset into our overall range, i.e. a value of 0 means we're
    #		at the start of the overall range.  Always points to the start of a
    #		range, or to the end (one-past-the-last) of the overall range.
    #		Dynamic field, changed by Advance() as we iterate.

    # Advances to the next subrange.
    # Tested by Test140205_0937.  -CMA 2014.02.05.
    sub Advance { my ($this) = @_; $this->[2] = _NextOffset($this); }

    # Returns the last position in the current subrange, i.e. this is *not* a
    # C++-style "one-past" end.
    sub End {
        my ($this) = @_;
        return $this->[0] + _NextOffset($this) - 1;
    }

    # Whether the current subrange is an "on" or "off" subrange.  Works by
    # getting the on or off state of the element of our states array at the
    # beginning of the current subrange.  Note that this uses the special Perl
    # nested-array syntax.
    sub IsOn { my ($this) = @_; return $this->[1][ $this->[2] ]; }

    # Works by seeing whether our current offset is still within our states
    # array.
    sub IsValid { my ($this) = @_; return $this->[2] < @{ $this->[1] }; }

    # The function parameters define the on & off positions by giving a default
    # state (on or off) and exceptions to that state.
    sub NewFromExceptions {
        my ( $Start, $End, $bDefOn, $raExcOffsets ) = @_;
        my @This;

        $This[0] = $Start;
        $This[1] = [];

        # Initialize the whole overall range to the default state.
        push( @{ $This[1] }, $bDefOn ) for $Start .. $End;

        # Set the exceptional positions to the nondefault state.
        $This[1][$_] = !$bDefOn for @$raExcOffsets;

        $This[2] = 0;    # Start at the beginning.
        return \@This;
    }

    # Returns the 1st position in the current subrange.
    sub Start { my ($this) = @_; return $this->[0] + $this->[2]; }

    sub _NextOffset {
        my ($this) = @_;

        # Starting at the next position after the current position, look for the
        # beginning of the next range.
        for ( my $TryOff = $this->[2] + 1 ; ; $TryOff++ ) {

            # Test for end of the overall range.
            return $TryOff if $TryOff > $#{ $this->[1] };

            # If we find a position whose state is opposite our current state,
            # then that's the beginning of the next range.
            return $TryOff if IsOn($this) != $this->[1][$TryOff];
        }
    }

}    # End package OnRangeItr.

###############################################################################
###############################################################################
# PACKAGE:  TheBwdPageState.  -CMA 2013.07.31.

# Encapsulates our URL param values, which constitute the state of this page for
# this page request.
{

    package TheBwdPageState;
    my $_rState;    # "The" BwdPageState object.  Set in Load().

###############################################################################
    # SUB:  TheBwdPageState::EndDate.
    sub EndDate {
        return BwdPageState::EndDate($_rState);
    }               # TheBwdPageState::EndDate.  -CMA 2013.08.04.

###############################################################################
    # SUB:  TheBwdPageState::Filter.
    # NOTES:  Besides just filtering, also sorts if there's a request to.
    sub Filter {    #my( $raProjsParam ) = @_;
        return BwdPageState::Filter( $_rState, TheProjs::rGetC() );
    }               # TheBwdPageState::Filter.  -CMA 2013.08.01.

###############################################################################
    # SUB:  TheBwdPageState::GetC.

    # NOTES:  This sub is provided for efficiency, but is logically const; don't
    # modify the returned object!
    sub GetC {
        if ( !defined( $_rState[15] ) || $_rState[15] !~ /^[-+]?\d+(\.\d+)?$/ )
        {
            $_rState[15] = '';
        }

        if ( !defined( $_rState[18] ) || $_rState[18] !~ /^[-+]?\d+(\.\d+)?$/ )
        {
            $_rState[18] = '';
        }

        return $_rState;
    }    # TheBwdPageState::GetC.  -CMA 2013.08.05.

###############################################################################
    # SUB:  TheBwdPageState::GetCopy.
    sub GetCopy {
        if ( !defined( $_rState[15] ) || $_rState[15] !~ /^[-+]?\d+(\.\d+)?$/ )
        {
            $_rState[15] = '';
        }

        if ( !defined( $_rState[18] ) || $_rState[18] !~ /^[-+]?\d+(\.\d+)?$/ )
        {
            $_rState[18] = '';
        }

        return BwdPageState::Copy($_rState);
    }    # TheBwdPageState::GetCopy.  -CMA 2013.08.04.

###############################################################################
    # SUB:  TheBwdPageState::IsMetric.
    sub IsMetric {
        return BwdPageState::IsMetric($_rState);
    }    # TheBwdPageState::IsMetric.  -CMA 2013.08.18.

###############################################################################
    # SUB:  TheBwdPageState::Load.
    sub Load {
        $_rState = BwdPageState::NewFromUrlParams();
    }    # TheBwdPageState::Load.  -CMA 2013.08.01.

###############################################################################
    # SUB:  TheBwdPageState::NextPageParams.
    # RETURN:  A list of alternating param names and values.
    sub NextPageParams {
        my $rNextState = BwdPageState::Copy($_rState);

        BwdPageState::SetPageStart( $rNextState, NextStartNum() );
        return BwdPageState::Params($rNextState);
    }    # TheBwdPageState::NextPageParams.  -CMA 2013.08.04.

###############################################################################
    # SUB:  TheBwdPageState::NextStartNum.
    sub NextStartNum {
        my $Start = BwdPageState::PageStart($_rState);

        return $Start + BwdPageState::PerPage($_rState);
    }    # TheBwdPageState::NextStartNum.  -CMA 2013.08.19.

###############################################################################
    # SUB:  TheBwdPageState::RequestedTreatments.
    sub RequestedTreatments {
        return BwdPageState::Treatments($_rState);
    }    # TheBwdPageState::RequestedTreatments.  -CMA 2013.08.04.

###############################################################################
    # SUB:  TheBwdPageState::ShouldShowTotals.
    sub ShouldShowTotals {
        return BwdPageState::ShouldShowTotals($_rState);
    }    # TheBwdPageState::ShouldShowTotals.  -CMA 2013.08.04.

###############################################################################
    # SUB:  TheBwdPageState::StartDate.
    sub StartDate {
        return BwdPageState::StartDate($_rState);
    }    # TheBwdPageState::StartDate.  -CMA 2013.08.04.

}    # End package TheBwdPageState.

###############################################################################
###############################################################################
# PACKAGE:  TheProjs.  -CMA 2013.07.25.

# Provides our collection of BAER project objects, derived from our database.
{

    package TheProjs;

    # Path to our XML database files (ends in "baer-db/").  Set in Init().
    our $DataPath;

    my $_raProjs;    # Our array of BaerProj project objects, set in Load().

###############################################################################
    # SUB:  TheProjs::rGetC.
    sub rGetC {
        return $_raProjs;
    }                # TheProjs::rGetC.  -CMA 2013.08.06.

###############################################################################
    # SUB:  TheProjs::Init.
    # ACTION:  Must be called on startup before our other member subs.
    sub Init {

        # CMA replaced 2014.01.23.
        #	$c_XmlPath = "../../../htdocs/BAERTOOLS/baer-db/";

        $DataPath = $ENV{DOCUMENT_ROOT} . "/BAERTOOLS/baer-db/";
    }    # TheProjs::Init.  -CMA 2014.01.23.

###############################################################################
    # SUB:  TheProjs::Load.
    sub Load {

        # It's much faster to load our data from a Storable than to build it
        # from scratch every time, so we use our cached TheProjs.sto if it's up
        # to date; otherwise we create it to use in future requests.
        # Tested by Test140206_1659.  -CMA 2014.02.07.
        return if _LoadFromSto();

    # If we get here, we didn't find a valid .sto; we have to fill $_rProjs from
    # scratch (from the XML exported from the mdb).

        # Parse the projects table XML file into a memory object.
        my $rProjsXml = XML::Simple::XMLin( $DataPath . "Projects.xml" );

      # Get the array of project elements in the XML file, and create a BaerProj
      # object from each one.
        for ( @{ $rProjsXml->{Projects} } ) {
            push @$_raProjs, BaerProj::NewFromMdb($_);
        }

        # Sort by date, newest first.
        @$_raProjs =
          sort { BaerProj::FireStrt($b) cmp BaerProj::FireStrt($a) } @$_raProjs;

        for ( 0 .. $#{$_raProjs} ) {

        # Note that we store reverse indexes.  This is so that if the browser is
        # holding indexes when we update the database, hopefully, if the update
        # is just to add newer projects, these indexes, starting from the
        # oldest, will still be good.  -CMA 2014.01.03.
            BaerProj::SetHandle( $_raProjs->[$_], $#{$_raProjs} - $_ );
        }

        # Parse the treatments table XML file.
        my $rTmtsXml = XML::Simple::XMLin( $DataPath . "Treatment Costs.xml" );

     # Each treatment belongs to a project, so for each treatment, find its
     # project object and add the treatment to it.  This is very slow (dozens of
     # seconds) due to m x n time complexity.  We could speed it up dramatically
     # by sorting the projects table on "ID" (fire & forest), then using binary
     # search to find each treatment's project, but this code only runs ~1x/year
     # in production, so why bother.
     #
     # The parsed XML hash, $rTmtsXml, contains a "Treatment_x0020_Costs" array
     # containing the treatments XML elements.
        for my $rTmt ( @{ $rTmtsXml->{Treatment_x0020_Costs} } ) {
            my $rFoundProj;

            for (@$_raProjs) {
                if ( BaerProj::OwnsTreatmentFromMdb( $_, $rTmt ) ) {
                    $rFoundProj = $_;
                    last;
                }
            }

            BaerProj::AddTreatmentFromMdb( $rFoundProj, $rTmt );
        }

        # Finally, now that we've built $_raProjs, save it to file for future
        # requests.
        Storable::store( $_raProjs, "TheProjs.sto" );
    }    # TheProjs::Load.  -CMA 2013.07.25.

###############################################################################
    # SUB:  TheProjs::FromHandle.
    sub FromHandle {
        my ($iHandle) = @_;

        # A "handle" is a reverse index into our array of projects.
        my $bOk = ( $iHandle >= 0 && $iHandle < @$_raProjs );

        # Handles come from the client, so they might not be valid.
        return $bOk ? $_raProjs->[ $#{$_raProjs} - $_ ] : undef;
    }    # TheProjs::FromHandle.  -CMA 2014.01.06.

###############################################################################
    # SUB:  TheProjs::_LoadFromSto.
    sub _LoadFromSto {
        my $bStorOk = my @StorStat = stat("TheProjs.sto");

     # TheProjs.sto, if it exists, needs to be newer than the XML files from
     # which it's derived.  This check is unfortunately not precise, because the
     # XML file has a dev-computer timestamp but the .sto file gets a server
     # timestamp, and the server time is far off (~1 hour fast at the moment).
     # This can be worked around because: (1) If we wait out the time difference
     # between creating and uploading a new XML file, then everything works
     # right; (2) if the server time is slow, it will just cause it to refresh
     # the .sto unnecessarily until it catches up; and (3) if the server time is
     # fast, then we could fail to use the freshest XML data, but that will only
     # happen if we're rapidly uploading new XML versions, and we can force an
     # update if necessary by just deleting the .sto.
     #
     # Of course, if we change the file format (by changing the data pattern in
     # BaerProj objects), we must delete the old .sto to force an update!
        for ( "Projects", "Treatment Costs" ) {
            if ($bStorOk) {
                my @XmlStat = stat("$DataPath$_.xml");

                # stat()[ 9 ] is the file change time, in seconds since 1970.
                $bStorOk = ( $StorStat[9] > $XmlStat[9] );
            }
        }

        # If we found a valid .sto, use it to fill $_rProjs.
        $_raProjs = Storable::retrieve("TheProjs.sto") if $bStorOk;
        return $bStorOk;
    }    # TheProjs::_LoadFromSto.  -CMA 2013.07.30.

}    # End package TheProjs.

###############################################################################
###############################################################################
# PACKAGE:  Treatment.  -CMA 2013.07.29.

# Handles Treatment objects (refs).  A Treatment represents a BAER treatment
# from our database.
{

    package Treatment;

    # A Treatment object is an array, with indices:
    #	0	Treatment description
    #	1	Unit of measure
    #	2	UnitCost
    #	3	NumberOfUnits
    #	4	NFSCost
    #	5	TotalCost

    #	6	Type (one of the 50+ rows in our DB Treatments table).
    #		-CMA 2014.01.15.

    # CMA deleted 2014.02.02.
    # This table converts misc. irregular treatment descriptions to a smaller
    # set of regularized descriptions.  It's not really important anymore
    # because we no longer try to present all of the descriptons in a list;
    # instead, we now use the treatments' newer "type" field.  Filled in Init().
    # -CMA 2014.01.15.
    #	my %_c_TmtEq;

###############################################################################
    # SUB:  Treatment::Descr.
    sub Descr {
        my ($this) = @_;
        return $this->[0];
    }    # Treatment::Descr.  -CMA 2014.01.15.

###############################################################################
    # SUB:  Treatment::Init.

   # ACTION:  Initializes data, because Perl lacks compile-time init.  Currently
   # does nothing, but we may as well leave the placeholder.  -CMA 2014.02.02.
    sub Init {

        # CMA deleted (unused) 2014.02.02.

=pod
	%_c_TmtEq = (
		"add culvert"      => "add culvert(s)",
		"add new culverts" => "add culvert(s)",
		"added culvert"    => "add culvert(s)",
		"added culverts"   => "add culvert(s)",
		"advisory letter"  => "advisory letter(s)",
		"advisory letters" => "advisory letter(s)",
		"Arch site protect"      => "arch site protect",
		"Arch Site Protect"      => "arch site protect",
		"arch site protection"   => "arch site protect",
		"arch site protectionng" => "arch site protect",
		"archy site protectiion" => "arch site protect",
		"archy site protection"  => "arch site protect",
		"ATV signage" => "ATV signs",
		"bio-control release"  => "bio-control release(s)",
		"bio-control releases" => "bio-control release(s)",
		"biocontrol release"   => "bio-control release(s)",
		"BLM fence"  => "BLM fence(s)",
		"BLM fences" => "BLM fence(s)",
		"cattle gueard" => "cattle guard",
		"channel debris removal" => "channel debris clearing",
		"clean culvert"        => "culvert clean",
		"clean culvert inlets" => "culvert clean",
		"clean culverts"       => "culvert clean",
		"closure gate"  => "closure gate(s)",
		"closure gates" => "closure gate(s)",
		"closure sign"    => "closure sign(s)",
		"closure signing" => "closure sign(s)",
		"closure signs"   => "closure sign(s)",
		"cultural resource prot" => "cultural resource protection",
		"cultural survey"  => "cultural survey(s)",
		"cultural surveys" => "cultural survey(s)",
		"culvert cleaning" => "culvert clean",
		"culvert cleanout" => "culvert clean",
		"culvert end section"  => "culvert end section(s)",
		"culvert end sections" => "culvert end section(s)",
		"culvert maint" => "culvert maintenance",
		"culvert replacement"  => "culvert replacement(s)",
		"culvert replacements" => "culvert replacement(s)",
		"culverttreatment" => "culvert treatments",
		"debris fence"  => "debris fence(s)",
		"debris fences" => "debris fence(s)",
		"diversion ditch"   => "diversion ditch(es)",
		"diversion ditches" => "diversion ditch(es)",
		"emergency coordinator" => "emergency coordination",
		"Fence"   => "fence",
		"fencing" => "fence",
		"fertilize - aerial" => "fertilization - aerial",
		"gate"  => "gate(s)",
		"Gate"  => "gate(s)",
		"gates" => "gate(s)",
		"Gates" => "gate(s)",
		"guard rail"  => "guard rail(s)",
		"guard rails" => "guard rail(s)",
		"gull stablization" => "gully stabilization",
		"haritage protection"      => "heritage site protection",
		"haritage site protection" => "heritage site protection",
		"hazard tree clearing" => "hazard tree removal",
		"hazard tree reomval-roads" => "hazard tree removal-roads",
		"HazMat stabilization" => "hazmat stabilization",
		"headcut stabilzation" => "headcut stabilization",
		"Herbicide" => "herbicide",
		"heritage protection" => "heritage site protection",
		"heritage site stabil" => "heritage site stabilization",
		"implentation team" => "implementation team",
		"in channel felling"      => "in-channel felling",
		"in channel tree felling" => "in-channel felling",
		"in-channel tree felling" => "in-channel felling",
		"install gate"  => "install gate(s)",
		"install gates" => "install gate(s)",
		"interagency coodination" => "interagency coordination",
		"interagency coord"       => "interagency coordination",
		"jersey barrier"  => "Jersey barrier(s)",
		"Jersey Barrier"  => "Jersey barrier(s)",
		"Jersey barriers" => "Jersey barrier(s)",
		"jersey barriers" => "Jersey barrier(s)",
		"low water crossing"  => "low water crossing(s)",
		"low water crossings" => "low water crossing(s)",
		"noxious weed treat"             => "noxious weed treatment(s)",
		"Noxious weed treatment"         => "noxious weed treatment(s)",
		"noxious weed treatment"         => "noxious weed treatment(s)",
		"noxious weed treatment-various" => "noxious weed treatment(s)",
		"noxious weed treatments"        => "noxious weed treatment(s)",
		"noxious weed trt"               => "noxious weed treatment(s)",
		"OHV Barrier"  => "OHV barrier(s)",
		"OHV barrier"  => "OHV barrier(s)",
		"OHV barriers" => "OHV barrier(s)",
		"ohv barriers" => "OHV barrier(s)",
		"OHV Barriers" => "OHV barrier(s)",
		"ohv closure" => "OHV closure",
		"ohv fencing" => "OHV fence",
		"ohv patrol"  => "OHV patrol",
		"OHV Patrol"  => "OHV patrol",
		"OHV patrols" => "OHV patrol",
		"OHV Pipe Rail barriers" => "OHV pipe rail barriers",
		"ohv signs" => "OHV signs",
		"over-side drains" => "overside drain(s)",
		"overside drain"   => "overside drain(s)",
		"overside drains"  => "overside drain(s)",
		"PAM12" => "PAM-12",
		"patrol,enforce travel plan" => "patrol and enforce travel plan",
		"public info" => "public information",
		"pull weeds"    => "weed pulling",
		"pulling weeds" => "weed pulling",
		"range rider"  => "range rider(s)",
		"range riders" => "range rider(s)",
		"raod closure" => "road closure",
		"recondition road"  => "recondition road(s)",
		"recondition roads" => "recondition road(s)",
		"rip rap" => "rip-rap",
		"riparian plantings" => "riparian planting",
		"riparian shrub planting" => "riparian planting shrubs",
		"road barrier"  => "road barrier(s)",
		"road barriers" => "road barrier(s)",
		"Road Closure" => "road closure",
		"road closure barrier"  => "road closure barrier(s)",
		"road closure barriers" => "road closure barrier(s)",
		"road closure gate"  => "road closure gate(s)",
		"road closure gates" => "road closure gate(s)",
		"Road drainage" => "road drainage",
		"road gate"  => "road gate(s)",
		"road gates" => "road gate(s)",
		"road maintain"    => "road maintenance",
		"Road maintenance" => "road maintenance",
		"Road obliteration" => "road obliteration",
		"road storm proofing" => "road stormproofing",
		"Road treatments"          => "road treatments",
		"Road treatments, various" => "road treatments",
		"road treatments, various" => "road treatments",
		"road work (undefined)"   => "road work",
		"road work-various treat" => "road work",
		"rock checkdams" => "rock check dams",
		"rock sed traps" => "rock sediment traps",
		"rock vane"  => "rock vane(s)",
		"rock vanes" => "rock vane(s)",
		"sandbags" => "sand bags",
		"signing" => "signs",
		"storm patrols" => "storm patrol",
		"structure prot"       => "structure protection",
		"Structure protection" => "structure protection",
		"trail closure sign"  => "trail closure sign(s)",
		"trail closure signs" => "trail closure sign(s)",
		"Weed Survey"  => "weed survey",
		"weed surveys" => "weed survey",
		"weed treatments" => "weed treatment",
		"weed treqtment"  => "weed treatment",
	);
=cut

    }    # Treatment::Init.  -CMA 2013.07.30.

###############################################################################
    # SUB:  Treatment::NewFromMdb.

 # NOTES:  The sub name "Mdb" is obsolete.  This sub takes a hash extracted from
 # the XML file exported from the Treatment Costs table in our Access BAER
 # database.  The Access file used to be an .mdb but it's not anymore.
 # -CMA 2013.08.28.
 #
 # Tested by Test140202_1533.  -CMA 2014.02.02.
    sub NewFromMdb {
        my ($rTmtFromXml) = @_;
        my @NewObj;
        my $Descr = $rTmtFromXml->{Treatment};

       # Trim surrounding whitespace.  This cleanup used to be important when we
       # were filtering and sorting on the actual descriptions.  Now these
       # anomalies aren't really important, just ugly, so we may as well keep
       # cleaning them up.  -CMA 2014.02.02.
        $Descr =~ s/^\s+//;
        $Descr =~ s/\s+$//;

      # CMA deleted 2014.02.02.
      # We probably don't really need to use these equivalents anymore, since we
      # no longer filter on descriptions, but I guess it still cleans up some
      # spelling errors.  -CMA 2014.01.15.
      #	my $DescrEquiv = $_c_TmtEq{ $Descr };

        $NewObj[0] = $Descr;                          # -CMA 2014.02.02.
        $NewObj[1] = $rTmtFromXml->{UnitofMeasure};
        $NewObj[2] = $rTmtFromXml->{UnitCost};
        $NewObj[3] = $rTmtFromXml->{NumberOfUnits};
        $NewObj[4] = $rTmtFromXml->{NFSCost};
        $NewObj[5] = $rTmtFromXml->{TotalCost};

    # The treatment's "type" (one of the 50+ rows in the DB's Treatments table).
    # I named this field in the DB's Treatment Costs table "Category", which I
    # shouldn't have because we already used the term Category to refer to the
    # major categories "Land Treatments", "Channel Treatments", &c.
    # -CMA 2014.01.15.
        $NewObj[6] = $rTmtFromXml->{Category};

        return \@NewObj;
    }    # Treatment::NewFromMdb.  -CMA 2013.07.30.

###############################################################################
    # SUB:  Treatment::NFSCost.
    sub NFSCost {
        my ($this) = @_;
        return $this->[4];
    }    # Treatment::NFSCost.  -CMA 2013.07.30.

###############################################################################
    # SUB:  Treatment::NumUnits.
    sub NumUnits {
        my ($this) = @_;
        return $this->[3];
    }    # Treatment::NumUnits.  -CMA 2013.07.30.

###############################################################################
    # SUB:  Treatment::TotalCost.
    sub TotalCost {
        my ($this) = @_;
        return $this->[5];
    }    # Treatment::TotalCost.  -CMA 2013.07.30.

###############################################################################
    # SUB:  Treatment::Type.
    sub Type {
        my ($this) = @_;
        return $this->[6];
    }    # Treatment::Type.  -CMA 2014.01.15.

###############################################################################
    # SUB:  Treatment::UnitCost.
    sub UnitCost {
        my ($this) = @_;
        return $this->[2];
    }    # Treatment::UnitCost.  -CMA 2013.07.30.

###############################################################################
    # SUB:  Treatment::Units.
    sub Units {
        my ($this) = @_;
        return $this->[1];
    }    # Treatment::Units.  -CMA 2013.07.30.

}    # End package Treatment.

# Standard "main script stub" for library file.  -CMA 2013.08.13.
1;

################################# END OF FILE #################################
