#!/usr/bin/perl

use strict;

package TimObj;

use TimUtil;

require Exporter;

our @ISA = qw(Exporter);

our @EXPORT = qw(
    E_INVALID_OBJECT
);

# Debugging
use constant DEBUG_OBJECT	=> 0x00010000;

# Unused place-holders...
use constant DEBUG_OBJECT1	=> 0x00020000;
use constant DEBUG_OBJECT2	=> 0x00040000;
use constant DEBUG_OBJECT3	=> 0x00080000;

my %DebugModes = ( 
    (DEBUG_OBJECT)        => {
        name    => "object",
        title   => "DEBUG_OBJECT",
    },  
);

# Object Error Messages
use constant E_INVALID_OBJECT	=> 10;
use constant E_NOT_IMPLEMENTED	=> 11;

my %ErrorMessages = (
    (E_INVALID_OBJECT)	=> {
        title	=> "E_INVALID_OBJECT",
        message	=> "Invalid Object",
    },
    (E_NOT_IMPLEMENTED)	=> {
        title	=> "E_NOT_IMPLEMENTED",
        message	=> "This function is not implemented",
    },
);

# Parameters...
my %ParamDefs = (
);

# Other Tings...

use constant MAX_NESTING_DEPTH	=> 10;

#
# Class Definition
#

# TimObj::new
# Constructor for the abstract base object class.
#
# new() accepts one argument: a hashref to the list of key=>value pairs
# from which to construct the object.
#
sub TimObj::new
{
    my ($class,$record) = @_;

    debugprint(DEBUG_TRACE, "Entering...");

    my $self = {};
    $self = $record if ref($record);

    $self->{GUID} = TimObj::genGUID();

    debugprint(DEBUG_OBJECT, "New object GUID: \"%s\"", $self->{GUID});

    if ( ref($self) ) {

        bless($self, $class);

    }
    else {  
        debugprint(DEBUG_ERROR, "Failed to create TimObj!");
        $self = undef;
    }

    debugprint(DEBUG_TRACE, "Returning %s", (UNIVERSAL::isa($self, "TimObj")?"SUCCESS":"FAILURE"));

    return $self;

}

# TimObj::init
# Initializer for the abstract base object class.
#
# init() accepts one argument, an objref to the owning object.
#
sub TimObj::init
{
    my $self = shift;
    my ($owner) = @_;
    my $returnval = E_NO_ERROR;

    debugprint(DEBUG_TRACE, "Entering...");

    unless ( $self->{initialized} ) {

        debugprint(DEBUG_OBJECT, "My Object Class: \"%s\"", $self->class());

        # Set up some very basic stuff...
        $self->{owner} = $owner;

        debugdump(DEBUG_DUMP, "self", $self);

        # See if there's an app lurking somewhere above us...
        debugprint(DEBUG_OBJECT, "Looking for the app...");

        # Check to see if we're the app...
        unless ( UNIVERSAL::isa($self, "TimApp") ) {

            # Check to see if we have an owner to ask...
            if ( ref($owner) ) {

                # Check to see if $owner knows who the app is...
                unless ( UNIVERSAL::isa($owner->{app}, "TimApp") ) {

                    # Point at our owner, to check that...
                    my $objref = $self->{owner};

                    while ( UNIVERSAL::isa($objref, "TimObj") ) {

                        debugprint(DEBUG_OBJECT, "Checking %s %s...", $objref->{class}, $objref->{GUID});

                        # Is this object the app?
                        if ( UNIVERSAL::isa($objref, "TimApp") ) {

                            debugprint(DEBUG_OBJECT, "Found the app: \"%s\"", $self->{app});
                            $self->{app} = $objref;
                            last;
                        }
                        else {

                            debugprint(DEBUG_OBJECT, "Not the app...");
                            unless ( $objref == $objref->{owner} ) {

                                debugprint(DEBUG_ERROR, "No more objects to check!");
                                $returnval = E_INVALID_OBJECT;
                                last;
                            }
                        }
                    }
                }
                else {
                    debugprint(DEBUG_OBJECT, "\$owner knew who the app was, setting {app} to %s", $owner->{app});
                    $self->{app} = $owner->{app};
                }
            }
            else {
                debugprint(DEBUG_WARN, "Waaaahhh!!!! I'm an orphan! (\$owner is not a ref)");
            }
        }
        else {
            debugprint(DEBUG_OBJECT, "No, wait... I AM the app!!!");
            $self->{app} = $self;
        }
    }
    else {
        debugprint(DEBUG_ERROR, "Already initialized!");
    }

    debugprint(DEBUG_TRACE, "Returning %s", error_message($returnval));

    return $returnval;
}

# TimObj::abstract
sub TimObj::abstract
{
    my $self = shift;
    my ($function_name) = @_;

    debugprint(DEBUG_ERROR, "Abstract Function called: '%s'", $function_name);
    return E_NOT_IMPLEMENTED;
}

# TimObj::class
sub TimObj::class
{
    my $self = shift;

    return (split('=', $self))[0];
}

# TimObj::genGUID
sub TimObj::genGUID
{
    return sprintf("%8.8X", rand(time()));
}

# TimObj::show_self
sub TimObj::show_self
{
    my $self = shift;

    debugdump(DEBUG_DUMP, "self", $self);
}

#
# Module Initialization
#

register_debug_modes(\%DebugModes);
register_error_messages(\%ErrorMessages);
register_params(\%ParamDefs);

# Done!

return SUCCESS;

