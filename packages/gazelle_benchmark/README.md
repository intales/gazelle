# Gazelle Benchmarks

This project is a really simple way to benchmark Gazelle performances.
Inspired by Fastify benchmarks.

## Description

The benchmark consists in running a simple server with a single route that response with `{ hello: 'world'}`.
Benchmark runs are done with `wrk` with these settings:
```sh
wrk -t12 -c400 -d30s http://localhost:3000/ --latency
```
I run this test on _my_ machine which is a 13-inch MacBook Pro (M1), 2020 with 8GB of RAM.
Maybe not the best computer to run this benchmarks, I'll work on a more generic setup like a linux machine with a decent
CPU and 16GB of RAM.

## Running the tests
To run this benchmark I'm using Dart AOT compiler, but you can run it with JIT if you want.
Inside `lib/gazelle_benchmark.dart` you can customize the server for the test as you like, then you only need to compile it
with `dart compile exe bin/gazelle_benchmark.dart -o bin/gazelle_benchmark`.
After that, you can run the `wrk` command mentioned in the description.

## Considerations
As you know, benchmarks are not a super reliable way to test perfomrances, as they depend on a number of enviromental factors
like machine setup, os, network and so on.
This is a basic test to see how much overhead does Gazelle add on top of Dart's `HttpServer` class.

Lastly, I think that this benchmarks need some work to be 100% belivable, comparisons with other frameworks
and servers would make this much better.

If you're interested in investigating on this subject, feel free to do it!

## Benchmarks result
These are the `wrk` results that I got on my machine:
```txt
—FIRST RUN—
Running 30s test @ http://localhost:3000/
  12 threads and 400 connections
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency     4.99ms  443.53us  28.27ms   96.56%
    Req/Sec     4.01k     2.24k   39.97k    66.56%
  Latency Distribution
     50%    4.95ms
     75%    5.01ms
     90%    5.09ms
     99%    5.99ms
  1438504 requests in 30.10s, 290.84MB read
  Socket errors: connect 157, read 87, write 0, timeout 0
Requests/sec:  47789.89
Transfer/sec:      9.66MB
—SECOND RUN—
Running 30s test @ http://localhost:3000/
  12 threads and 400 connections
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency     4.96ms    0.97ms 109.31ms   99.59%
    Req/Sec     5.39k     1.82k   12.01k    88.68%
  Latency Distribution
     50%    4.95ms
     75%    5.00ms
     90%    5.05ms
     99%    5.17ms
  1451282 requests in 30.10s, 293.42MB read
  Socket errors: connect 157, read 79, write 0, timeout 0
Requests/sec:  48209.72
Transfer/sec:      9.75MB
—THIRD RUN—
Running 30s test @ http://localhost:3000/
  12 threads and 400 connections
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency     5.01ms  246.40us  33.23ms   97.62%
    Req/Sec     3.99k     2.62k   11.39k    51.44%
  Latency Distribution
     50%    5.00ms
     75%    5.08ms
     90%    5.16ms
     99%    5.29ms
  1431684 requests in 30.06s, 289.46MB read
  Socket errors: connect 157, read 64, write 0, timeout 0
Requests/sec:  47624.01
Transfer/sec:      9.63MB
—FOURTH RUN—
Running 30s test @ http://localhost:3000/
  12 threads and 400 connections
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency     5.03ms    1.66ms 133.12ms   99.57%
    Req/Sec     4.00k     2.07k   21.90k    49.92%
  Latency Distribution
     50%    4.99ms
     75%    5.07ms
     90%    5.15ms
     99%    5.27ms
  1434263 requests in 30.10s, 289.98MB read
  Socket errors: connect 157, read 137, write 0, timeout 0
Requests/sec:  47649.16
Transfer/sec:      9.63MB
—FIFTH RUN—
Running 30s test @ http://localhost:3000/
  12 threads and 400 connections
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency     5.00ms  646.94us  84.59ms   99.43%
    Req/Sec     4.01k     2.30k   11.87k    41.84%
  Latency Distribution
     50%    4.98ms
     75%    5.06ms
     90%    5.14ms
     99%    5.27ms
  1437877 requests in 30.10s, 290.71MB read
  Socket errors: connect 157, read 70, write 0, timeout 0
Requests/sec:  47764.29
Transfer/sec:      9.66MB
```
