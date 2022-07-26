## ----06-ex-e0, message=FALSE, include=TRUE-------------------------------------------------------------------------------------------------------------------------------------
library(sf)
library(terra)
library(spData)
zion_points_path = system.file("vector/zion_points.gpkg", package = "spDataLarge")
zion_points = read_sf(zion_points_path)
srtm = rast(system.file("raster/srtm.tif", package = "spDataLarge"))
ch = st_combine(zion_points) |>
  st_convex_hull() |> 
  st_as_sf()


## ----06-ex-e1------------------------------------------------------------------------------------------------------------------------------------------------------------------
plot(srtm)
plot(st_geometry(zion_points), add = TRUE)
plot(ch, add = TRUE)

srtm_crop1 = crop(srtm, vect(zion_points))
srtm_crop2 = crop(srtm, vect(ch))
plot(srtm_crop1)
plot(srtm_crop2)

srtm_mask1 = mask(srtm, vect(zion_points))
srtm_mask2 = mask(srtm, vect(ch))
plot(srtm_mask1)
plot(srtm_mask2)


## ----06-ex-e2------------------------------------------------------------------------------------------------------------------------------------------------------------------
zion_points_buf = st_buffer(zion_points, dist = 90)
plot(srtm)
plot(st_geometry(zion_points_buf), add = TRUE)
plot(ch, add = TRUE)

zion_points_points = extract(srtm, vect(zion_points))
zion_points_buf = extract(srtm, vect(zion_points_buf))
plot(zion_points_points$srtm, zion_points_buf$srtm2)


## ----06-ex-e3------------------------------------------------------------------------------------------------------------------------------------------------------------------
nz_height3100 = dplyr::filter(nz_height, elevation > 3100)
new_graticule = st_graticule(nz_height3100, datum = "EPSG:2193")
plot(st_geometry(nz_height3100), graticule = new_graticule, axes = TRUE)

nz_template = rast(ext(nz_height3100), resolution = 3000, crs = crs(nz_height3100))

nz_raster = rasterize(vect(nz_height3100), nz_template, 
                       field = "elevation", fun = "length")
plot(nz_raster)
plot(st_geometry(nz_height3100), add = TRUE)

nz_raster2 = rasterize(vect(nz_height3100), nz_template, 
                       field = "elevation", fun = max)
plot(nz_raster2)
plot(st_geometry(nz_height3100), add = TRUE)


## ----06-ex-e4------------------------------------------------------------------------------------------------------------------------------------------------------------------
nz_raster_low = raster::aggregate(nz_raster, fact = 2, fun = sum, na.rm = TRUE)
res(nz_raster_low)

nz_resample = resample(nz_raster_low, nz_raster)
plot(nz_raster_low)
plot(nz_resample) # the results are spread over a greater area and there are border issues
plot(nz_raster)


## Advantages:

## 

## - lower memory use

## - faster processing

## - good for viz in some cases

## 

## Disadvantages:

## 

## - removes geographic detail

## - adds another processing step


## ----06-ex-e5------------------------------------------------------------------------------------------------------------------------------------------------------------------
grain = rast(system.file("raster/grain.tif", package = "spData"))


## ----06-ex-e5-2----------------------------------------------------------------------------------------------------------------------------------------------------------------
grain_poly = as.polygons(grain) |> 
  st_as_sf()
levels(grain)
clay = dplyr::filter(grain_poly, grain == "clay")
plot(clay)


## Advantages:

## 

## - can be used to subset other vector objects

## - can do affine transformations and use sf/dplyr verbs

## 

## Disadvantages:

## 

## - better consistency

## - fast processing on some operations

## - functions developed for some domains

