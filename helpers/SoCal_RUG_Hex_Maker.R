###########################################################################
###                                                                     ###
### The hex logo was created with the {hexSticker} package for R        ###
### GitHub repo: https://github.com/GuangchuangYu/hexSticker            ###
###                                                                     ###
###########################################################################

# install.packages(c("hexSticker", "here"), repos = "https://cloud.r-project.org")
library(hexSticker)

imgurl <- here::here("images", "SoCal_RUG_White_Stacked.png")

hexSticker::sticker(imgurl, 
                    package = "",        # required name argument
                    s_x = 1, 
                    s_y = 1, 
                    s_height = 0.8,
                    s_width = 0.8,
                    h_fill = "#FFFFFF",  # background color
                    h_color = "#05173B", # border color
                    filename = here::here("images", "SoCal_RUG_Hex.png"))
