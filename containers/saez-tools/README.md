Repository with base R 4.1.2 and main R packages installed for using SaezLab tools

Build

> sudo singularity build saeztools.sif saeztools.singularity

Test

```
> chmod +x saeztools.sif
> ./saeztools.sif
```

Sign

```
> singularity key list
> singularity sign --keyidx N saeztools.sif
> singularity push saeztools.sif library://pablormier/permedcoe/saeztools:1.0.0

```
