#!/usr/local/bin/perl
# Display all custom fields for domains

require './virtual-server-lib.pl';
&can_edit_templates() || &error($text{'newfields_ecannot'});
&ui_print_header(undef, $text{'newfields_title'}, "", "custom_fields");

print "$text{'newfields_descr'}<p>\n";

# Make the table data
@fields = &list_custom_fields();
$i = 0;
@table = ( );
foreach $f (@fields, { }, { }) {
	push(@table, [
		&ui_textbox("name_$i", $f->{'name'}, 15),
		&ui_textbox("desc_$i", $f->{'desc'}, 45),
		&ui_select("type_$i", $f->{'type'},
			   [ map { [ $_, $text{'newfields_type'.$_} ] } (0 .. 10) ]).
		&ui_textbox("opts_$i", $f->{'opts'}, 25),
		&ui_checkbox("show_$i", 1, $text{'newfields_show2'},
			     $f->{'show'}),
		]);
	$i++;	
	}

# Render it
print &ui_form_columns_table(
	"save_newfields.cgi",
	[ [ "save", $text{'save'} ] ],
	0,
	undef,
	undef,
	[ $text{'newfields_name'}, $text{'newfields_desc'},
	  $text{'newfields_type'}, $text{'newfields_show'} ],
	100,
	\@table,
	undef,
	1);

&ui_print_footer("", $text{'index_return'});

