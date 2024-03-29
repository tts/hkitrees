library(tidyverse)
library(sf)

# https://hri.fi/data/fi/dataset/paakaupunkiseudun-aluejakokartat
districts <- st_read("PKS_suuralue.kml")

hki <- districts %>%
  filter(Name %in% c("Eteläinen", "Itäinen","Läntinen","Kaakkoinen",
                     "Keskinen","Pohjoinen","Koillinen")) %>% 
  mutate(Name_en = case_when(
    Name == "Eteläinen" ~ "South",
    Name == "Itäinen" ~ "East",
    Name == "Läntinen" ~ "West",
    Name == "Kaakkoinen" ~ "South East",
    Name == 'Keskinen' ~ "Center",
    Name == 'Pohjoinen' ~ "North",
    Name == "Koillinen" ~ "North East"
  ))

trees <- readRDS("hki_trees.RDS")

# https://gist.github.com/andrewheiss/0580d6ffec37b6bc4d0ae8e77bf30956
t2 <- trees %>%
  st_transform(crs = 4326)

t2_with_lat_lon <- cbind(t2, st_coordinates(t2))

# General
p <- ggplot(hki) + geom_sf() 
p <- p + geom_sf_text(aes(label = Name_en), colour = "Black") 
p <- p + geom_sf(data = trees[1:5000,], color= alpha("darkgreen", 0.3)) +
  labs(title = 'Sample of trees in Helsinki and their location',
       subtitle = "District boundaries don't show the shoreline in S/SE") +
  theme(axis.title = element_blank())
p

ggsave(
  "yleiskuva.png",
  units = "cm",
  width = 25,
  height = 30
)

# Density
p <- ggplot() +
  stat_density2d(data = t2_with_lat_lon, 
                 aes(x = X, y = Y, fill = ..density..), 
                 geom = 'tile', contour = F, alpha = .5) +  
  scale_fill_viridis_c() +
  labs(title = 'Tree density in Helsinki',
       fill = str_c('Nr or', '\ntrees')) +
  theme(axis.text = element_blank(),
        axis.title = element_blank(),
        axis.ticks = element_blank()) +
  guides(fill = guide_legend(override.aes = list(alpha = 1)))

p

ggsave(
  "puut.png",
  units = "cm",
  width = 20,
  height = 20
)

# Most common
common_trees <- t2_with_lat_lon %>%
  group_by(suku) %>%
  mutate(lkm = n()) %>%
  filter(lkm >= 1400)

ggplot() +
  stat_density2d(data = common_trees, 
                 aes(x = X, y = Y,
                     fill = stat(nlevel)), 
                 geom = 'polygon') +
  labs(title = 'The most common tree families in Helsinki',
       subtitle = str_c('Upper row: linden (lehmus), maple (vaahtera), birch (koivu), elm (jalava)\n',
                        'Lower row: rowan (pihlaja), oak (tammi), pine (mänty), alder (leppä)'),
       fill = 'Density') +
  theme(axis.text = element_blank(),
        axis.title = element_blank(),
        axis.ticks = element_blank()) +
  facet_wrap(. ~ reorder(common_trees$suku, -common_trees$lkm), ncol = 4) +
  scale_fill_viridis_c() 

ggsave(
  "tiheys.png",
  units = "cm",
  width = 30,
  height = 25
)

# Size
p <- ggplot() +
  stat_density2d(data = t2_with_lat_lon, 
                 aes(x = X, y = Y,
                     fill = stat(nlevel)), 
                 geom = 'polygon') +
  labs(title = 'The size of trees in Helsinki',
       subtitle = 'Size = diameter at chest height',
       fill = 'Density') +
  theme(axis.text = element_blank(),
        axis.title = element_blank(),
        axis.ticks = element_blank()) +
  facet_wrap(. ~ kokoluokka, ncol = 3) +
  scale_fill_viridis_c() 

p

ggsave(
  "koko.png",
  units = "cm",
  width = 30,
  height = 25
)


# Most near and most far from home
home <- st_sfc(st_point(c([your_lat_here],[your_lon_here])), crs = 4326)
home2 <- st_transform(home, crs = 4326)
most_near <- t2[which.min(st_distance(home2, t2[1:nrow(t2),])),]
most_far <- t2[which.max(st_distance(home2, t2[1:nrow(t2),])),]
st_distance(home2, most_near, by_element = T)
st_distance(home2, most_far, by_element = T)

near_far <- rbind(most_near, most_far)
mapview::mapview(near_far)

# Thuja family
thujas <- t2 %>% filter(suku == 'Thuja')
most_near_thuja <- thujas[which.min(st_distance(home2, thujas[1:nrow(thujas),])),]


