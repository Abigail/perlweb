use Test::More qw(no_plan);
use strict;
use Test::Benchmark;
use Data::Dumper;

use_ok('Combust::Cache');

for my $cache_backend (qw(dbi memcached)) {
  ok(Combust::Cache->backend($cache_backend), "set backend to $cache_backend");
  ok(my $cache = Combust::Cache->new(type=>"test"), "new Cache object (backend $cache_backend)");

  ok($cache->store(id => "test1", data => "T1"), "store simple data");
  ok(my $d = $cache->fetch(id => "test1"), "fetch simple data");
  is($d->{data}, "T1", "test simple data");
 
  ok($cache->store(id => "test2", data => ["T2"]), "store reference data");
  ok($d = $cache->fetch(id => "test2"), "fetch reference data");
  is_deeply($d->{data}, ["T2"], "test reference data");
  
  ok($cache->store(id => "test3", data => "T3", meta_data => { m => "x1"} ), "store meta_data");
  ok($d = $cache->fetch(id => "test3"), "fetch meta_data");
  is($d->{data}, "T3", "test meta_data test data");
  is_deeply($d->{meta_data}, {m=>"x1"}, "test meta_data"); 
  
  is($cache->fetch(id => "no_such_key"), undef, "get undefined return from non-existing cache key");
}

ok(my $cache = Combust::Cache->new(type=>"test"), "new Cache object");
ok($cache->backend('memcached'), "change backend to memcached");
is($cache->backend, "memcached", "backend is memcached");
isa_ok($cache, "Combust::Cache::Memcached"); 
ok($cache->backend('dbi'), "change backend to dbi");
isa_ok($cache, "Combust::Cache::DBI"); 

# test setting an invalid backend

#warn Data::Dumper->Dump([\$d], [qw(d)]);

if ($ENV{CACHE_BENCHMARK}) { 
  my $cache = Combust::Cache->new(type=>"test");
use Benchmark qw(timethese);
  timethese(50,
	    {
	     'memcached_store' => sub {
	       $cache->backend('memcached');
	       store_many($cache);
	     },
	     'dbi_store' => sub {
	       $cache->backend('dbi');
	       store_many($cache);
	     }
	    },
	   );
  
  $^W=0;
  
  timethese(50,
	    {
	     'memcached_fetch' => sub {
	       $cache->backend('memcached');
	       fetch_many($cache);
	     },
	     'dbi_fetch' => sub {
	       $cache->backend('dbi');
	       fetch_many($cache);
	     }
	   },
);


}

sub store_many {
  my $data = { test => "foo", blah => join("", ("x")x5000) };
  my $cache = shift;
  for my $i (50..1000) {
    $cache->store(id => "b$i", data => $data);
  }
}


sub fetch_many {
  my $cache = shift;
  for my $i (1..1050) {
    $cache->fetch(id => "b$i");
  }
}
