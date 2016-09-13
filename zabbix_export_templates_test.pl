#!/usr/bin/perl -w
use strict;
use warnings;
use JSON::RPC::Legacy::Client;
use XML::LibXML;

#my $url      = 'http://10.95.229.132:8885/zabbix/api_jsonrpc.php'; # URL to Zabbix
my $url      = 'http://localhost/zabbix/api_jsonrpc.php'; # URL to Zabbix
my $userid   = "Admin";                                 # Zabbix API User ID
my $password = "h1ppj0kk";                             # Zabbix API User Password
my $destDir  = "./templates";

my $client = new JSON::RPC::Legacy::Client;

my $authID = authenticate();
my $response = listTemplates();

# Check if response was successful
die "template.get failed\n" unless $response->content->{result};

unless (-d "$destDir") {
  mkdir "$destDir" or die "$!";
}

foreach my $host (@{$response->content->{result}}) {
  # print "Template: ".$host->{host}."\n";
  # print "TemplateID: ".$host->{templateid}."\n";
  getTemplates($host->{templateid}, $host->{host});
}

exit(0);

# Authenticate
sub authenticate{
  my $json = {
    jsonrpc => "2.0",
    method => "user.login",
    params => {
      user => "$userid",
      password => "$password"
    },
    id => 1
  };

  $response = $client->call($url, $json);
    die "Authentication failed\n" unless $response->content->{'result'};

  return $response->content->{'result'};
}

# Get list of all Templates
sub listTemplates{
  my $json = {
    jsonrpc => '2.0',
    method  => 'template.get',
    params  =>  {
      output => "extend",
     # filter => {
     #   host => "t.app.strongmail"
     #   }
    },
    id   => 2,
    auth => "$authID",
  };
  return $client->call($url, $json);
}

# Get Templates and save to individual XML files
sub getTemplates{
  my $templateid = shift;
  my $templatename = shift;

  print "TemplateID: $templateid\n";
  print "templatename: $templatename\n";

  my $json = {
    jsonrpc => '2.0',
    method  => 'configuration.export',
    params  =>  {
        options => {
            templates => ["$templateid"]
        },
        format => "xml"
    },
    id   => 7,
    auth => "$authID",
  };

  $response = $client->call($url, $json);
    die "Authentication failed\n" unless $response->content->{'result'};

  my $doc = XML::LibXML->load_xml(string => $response->content->{'result'}, { no_blanks => 1 });
  my $output = $doc->toString(1);

  open (MYFILE, ">", "$destDir/$templatename.xml") or die "$!";
  print MYFILE $output;
  close (MYFILE);
}
