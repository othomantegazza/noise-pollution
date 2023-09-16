# Content

Code to explore environmental noise data collected with Phyphox.

# Deploy Locally

!You need the data though, that at this moment are kept private!

To deploy locally:

1. Install Quarto: https://quarto.org/docs/get-started/

2. Open `quarto-example.Rproj` in Rstudio.

3. At the R console, install all R packages with:

```r
renv::restore()
```

4 At the shell console, deploy the slides with:

```sh
quarto preview
```

The analysis will be available at localhost:4200.

# License

See file [LICENSE](LICENSE)
