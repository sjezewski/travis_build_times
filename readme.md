# Travis Build Times

We noticed some slowness on travis, so figured I'd take a look.

Goal here was to calculate the likelihood a build will timeout given the current elapsed duration of the build.

The data was split into two sets:

- 'control' which is all of our travis builds between 2016/03 - 2016/11/18
- 'upgradedVM' which is once travis upgraded our machine .... 11/18-12/20

To run:

```
make local
```

You'll need rvm / ruby / gnuplot.

Didn't quite finish setting it up as a pachyderm pipeline. With the services feature about to land, it would be cool to have the final 'pipeline' be a job hosting the png's generated by gnuplot