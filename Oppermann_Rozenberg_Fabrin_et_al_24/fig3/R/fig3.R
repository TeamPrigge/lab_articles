library(ggplot2)
library(ggpubr)
library(dplyr)
library(patchwork)
library(drc)

#load data ----
data <- read.csv("data/data1.csv")
glimpse(data)

df.msacr1 <- data |>
  filter(recording == 1)

#----
#general objects and plot functions ----

plot.msacr1.f1 <- function(graph) {
  graph +
    #connect samples
    geom_line(aes(group = index),
              show.legend = FALSE,
              color = "lightgray") +
    #samples
    geom_point(aes(fill = "treatment"),
               size = 3,
               alpha = 0.8,
               show.legend = FALSE) +
    #summary
    stat_summary(fun.min = mean,
                 geom = "errorbar",
                 color = "black",
                 width = 0.5,
                 lwd = 1) +
    stat_summary(fun.data = "mean_se",
                 geom = "linerange",
                 color = "black",
                 lwd = 0.8) +
    #axis
    scale_y_continuous(expand = c(0,0),
                       limits = c(0, max(df.msacr1$spikes, na.rm = TRUE) + 3)) +
    ylab("Spikes") +
    #graph
    theme_classic() +
    theme(axis.title.x = "element_text"(size = 9)) +
    theme(axis.title.y = "element_text"(size = 12)) +
    theme(axis.text.x  = "element_text"(size = 8,
                                        hjust = 0.5)) +
    theme(axis.text.y  = "element_text"(size = 11)) +
    geom_point(color = "black", pch = 21, size = 3)
}
plot.msacr1.f2 <- function(graph) {
  graph +
    theme_classic() +
    theme(axis.title.x = "element_text"(size = 10)) +
    theme(axis.title.y = "element_text"(size = 10)) +
    theme(axis.text.x  = "element_text"(size = 8,
                                        hjust = 0.5)) +
    theme(axis.text.y  = "element_text"(size = 11))
}
plot.msacr1.f3 <- function(graph) {
  graph +
    #connect samples
    geom_line(aes(group = index),
              show.legend = FALSE,
              color = "lightgray") +
    #samples
    geom_point(aes(fill = "treatment"),
               size = 3,
               alpha = 0.8,
               show.legend = FALSE) +
    #summary
    stat_summary(fun.min = mean,
                 geom = "errorbar",
                 color = "black",
                 width = 0.5,
                 lwd = 1) +
    stat_summary(fun.data = "mean_se",
                 geom = "linerange",
                 color = "black",
                 lwd = 0.8) +
    #axis
    scale_y_continuous(expand = c(0,0),
                       limits = c(0, max(df.msacr1$pa_inj, na.rm = TRUE)+40)) +
    ylab("Rheobase (pA)") +
    #graph
    theme_classic() +
    theme(axis.title.x = "element_text"(size = 9)) +
    theme(axis.title.y = "element_text"(size = 12)) +
    theme(axis.text.x  = "element_text"(size = 8,
                                        hjust = 0.5)) +
    theme(axis.text.y  = "element_text"(size = 11)) +
    geom_point(color = "black", pch = 21, size = 3)
  }

#----
#tp184 550nm cont ******** ----
df.tp184.550nm.cont <- filter(df.msacr1, opsin == "tp184" & light == "550nm" &
                           treatment2 == "continuous")
head(df.tp184.550nm.cont)
#----
#tp184 550nm cont stat ----
tp184.550nm.cont.stat <- compare_means(spikes ~ treatment,
                                       df.tp184.550nm.cont,
                                       paired = TRUE,
                                       method = "wilcox.test",
                                       p.adjust.method = "bonferroni")
tp184.550nm.cont.stat
#----
#tp184 550nm cont plot ----
tp184.550nm.cont.plot <- ggplot(df.tp184.550nm.cont, aes(x = treatment, y = spikes,
                                                         color = treatment)) +
  #x axis
  scale_x_discrete(limit = c("ramp_no_light", "ramp_550nm_continuous"),
                   labels = c("No light", "550 nm")) +
  scale_color_manual(values = c("#0f9b48", "lightgray")) +
  #stat
  annotate("text", x = 1.5, y = max(df.msacr1$spikes, na.rm = TRUE) + 1, 
           label = tp184.550nm.cont.stat$p.signif,
           size = 5) +
  #plot title
  xlab("WT - Continuous")

  tp184.550nm.cont.plot <- plot.msacr1.f1(tp184.550nm.cont.plot)
  
  tp184.550nm.cont.plot

#----
#----
#tp184 550nm pulse ******** ----

df.tp184.550nm.pulse <- filter(df.msacr1, opsin == "tp184" & light == "550nm" &
                               treatment2 == "pulse")
head(df.tp184.550nm.pulse)
#----
#tp184 550nm pulse stat ----
#test
tp184.550nm.pulse.stat <- compare_means(spikes ~ treatment,
                                       df.tp184.550nm.pulse,
                                       paired = TRUE,
                                       method = "wilcox.test",
                                       p.adjust.method = "bonferroni")
tp184.550nm.pulse.stat
#----
#tp184 550nm pulse plot ----
  
tp184.550nm.pulse.plot <- ggplot(df.tp184.550nm.pulse, aes(x = treatment, y = spikes,
                                                           color = treatment)) +
  #x axis
  scale_x_discrete(limit = c("ramp_no_light", "ramp_550nm_pulse"),
                   labels = c("No light", "550 nm")) +
  scale_color_manual(values = c("#0f9b48", "lightgray")) +
  #stat
  annotate("text", x = 1.5, y = max(df.msacr1$spikes, na.rm = TRUE) + 1, 
           label = tp184.550nm.pulse.stat$p.signif,
           size = 5) +
  #plot title
  xlab("WT - 10 Hz")
  
  tp184.550nm.pulse.plot <- plot.msacr1.f1(tp184.550nm.pulse.plot)

tp184.550nm.pulse.plot

# #----
# #tp184 635nm cont ******** ----

df.tp184.635nm.cont <- filter(df.msacr1, opsin == "tp184" & light == "635nm" &
                                treatment2 == "continuous")
head(df.tp184.635nm.cont)
#----
#tp184 635nm cont stat ----
#test

tp184.635nm.cont.stat <- compare_means(spikes ~ treatment,
                                       df.tp184.635nm.cont,
                                       paired = TRUE,
                                       method = "wilcox.test",
                                       p.adjust.method = "bonferroni")
tp184.635nm.cont.stat
#----
#tp184 635nm cont plot ----

tp184.635nm.cont.plot <- ggplot(df.tp184.635nm.cont, aes(x = treatment, y = spikes,
                                                         color = treatment)) +
  #x axis
  scale_x_discrete(limit = c("ramp_no_light", "ramp_635nm_continuous"),
                   labels = c("No light", "635 nm")) +
  scale_color_manual(values = c("#d04826", "lightgray")) +
  #stat
  annotate("text", x = 1.5, y = max(df.msacr1$spikes, na.rm = TRUE) + 1, 
           label = tp184.635nm.cont.stat$p.signif,
           size = 5) +
  #plot title
  xlab("WT - Continuous")

tp184.635nm.cont.plot <- plot.msacr1.f1(tp184.635nm.cont.plot)

tp184.635nm.cont.plot

#----
#tp184 635nm pulse ******** ----

df.tp184.635nm.pulse <- filter(df.msacr1, opsin == "tp184" & light == "635nm" &
                                 treatment2 == "pulse")
head(df.tp184.635nm.pulse)
#----
#tp184 635nm pulse stat ----
#test

tp184.635nm.pulse.stat <- compare_means(spikes ~ treatment,
                                        df.tp184.635nm.pulse,
                                        paired = TRUE,
                                        method = "wilcox.test",
                                        p.adjust.method = "bonferroni")
tp184.635nm.pulse.stat
#----
#tp184 635nm pulse plot ----

tp184.635nm.pulse.plot <- ggplot(df.tp184.635nm.pulse, aes(x = treatment, y = spikes,
                                                           color = treatment)) +
  #x axis
  scale_x_discrete(limit = c("ramp_no_light", "ramp_635nm_pulse"),
                   labels = c("No light", "635 nm")) +
  scale_color_manual(values = c("#d04826", "lightgray")) +
  #stat
  annotate("text", x = 1.5, y = max(df.msacr1$spikes, na.rm = TRUE) + 1, 
           label = tp184.635nm.pulse.stat$p.signif,
           size = 5) +
  #plot title
  xlab("WT - 10 Hz")

tp184.635nm.pulse.plot <- plot.msacr1.f1(tp184.635nm.pulse.plot)

tp184.635nm.pulse.plot
(tp184.550nm.cont.plot | tp184.550nm.pulse.plot | tp184.635nm.cont.plot | tp184.635nm.pulse.plot)

#tp185 S218A
#tp185 550nm cont ******** ----

df.tp185.550nm.cont <- filter(df.msacr1, opsin == "tp185" & light == "550nm" &
                                treatment2 == "continuous")
head(df.tp185.550nm.cont)
#----
#tp185 550nm cont stat ----
#test
tp185.550nm.cont.stat <- compare_means(spikes ~ treatment,
                                       df.tp185.550nm.cont,
                                       paired = TRUE,
                                       method = "wilcox.test",
                                       p.adjust.method = "bonferroni")
tp185.550nm.cont.stat
#----
#tp185 550nm cont plot ----

tp185.550nm.cont.plot <- ggplot(df.tp185.550nm.cont, aes(x = treatment, y = spikes,
                                                         color = treatment)) +
  #x axis
  scale_x_discrete(limit = c("ramp_no_light", "ramp_550nm_continuous"),
                   labels = c("No light", "550 nm")) +
  scale_color_manual(values = c("#0f9b48", "lightgray")) +
  #stat
  annotate("text", x = 1.5, y = max(df.msacr1$spikes, na.rm = TRUE) + 1, 
           label = tp185.550nm.cont.stat$p.signif,
           size = 5) +
  #plot title
  xlab("S218A - Continuous")

tp185.550nm.cont.plot <- plot.msacr1.f1(tp185.550nm.cont.plot)

tp185.550nm.cont.plot

#----
#tp185 550nm pulse ******** ----

df.tp185.550nm.pulse <- filter(df.msacr1, opsin == "tp185" & light == "550nm" &
                                 treatment2 == "pulse")
head(df.tp185.550nm.pulse)
#----
#tp185 550nm pulse stat ----
#test

tp185.550nm.pulse.stat <- compare_means(spikes ~ treatment,
                                        df.tp185.550nm.pulse,
                                        paired = TRUE,
                                        method = "t.test",
                                        p.adjust.method = "bonferroni")
tp185.550nm.pulse.stat

tp185.550nm.pulse.stat.wilcox <- compare_means(spikes ~ treatment,
                                        df.tp185.550nm.pulse,
                                        paired = TRUE,
                                        method = "wilcox.test",
                                        p.adjust.method = "bonferroni")
tp185.550nm.pulse.stat.wilcox


tp185.550nm.pulse.stat.wilcox <- compare_means(spikes ~ treatment,
                                        df.tp185.550nm.pulse,
                                        paired = TRUE,
                                        method = "wilcox.test",
                                        p.adjust.method = "bonferroni")
tp185.550nm.pulse.stat.wilcox
#----
#tp185 550nm pulse plot ----

tp185.550nm.pulse.plot <- ggplot(df.tp185.550nm.pulse, aes(x = treatment, y = spikes,
                                                           color = treatment)) +
  #x axis
  scale_x_discrete(limit = c("ramp_no_light", "ramp_550nm_pulse"),
                   labels = c("No light", "550 nm")) +
  scale_color_manual(values = c("#0f9b48", "lightgray")) +
  #stat
  annotate("text", x = 1.5, y = max(df.msacr1$spikes, na.rm = TRUE) + 1, 
           label = tp185.550nm.pulse.stat$p.signif,
           size = 5) +
  #plot title
  xlab("S218A - 10 Hz")

tp185.550nm.pulse.plot <- plot.msacr1.f1(tp185.550nm.pulse.plot)

tp185.550nm.pulse.plot
#tp185 635nm cont ******** ----

df.tp185.635nm.cont <- filter(df.msacr1, opsin == "tp185" & light == "635nm" &
                                treatment2 == "continuous")
head(df.tp185.635nm.cont)
#----
#tp185 635nm cont stat ----
#test

tp185.635nm.cont.stat <- compare_means(spikes ~ treatment,
                                       df.tp185.635nm.cont,
                                       paired = TRUE,
                                       method = "wilcox.test",
                                       p.adjust.method = "bonferroni")
tp185.635nm.cont.stat
#----
#tp185 635nm cont plot ----

tp185.635nm.cont.plot <- ggplot(df.tp185.635nm.cont, aes(x = treatment, y = spikes,
                                                         color = treatment)) +
  #x axis
  scale_x_discrete(limit = c("ramp_no_light", "ramp_635nm_continuous"),
                   labels = c("No light", "635 nm")) +
  scale_color_manual(values = c("#d04826", "lightgray")) +
  #stat
  annotate("text", x = 1.5, y = max(df.msacr1$spikes, na.rm = TRUE) + 1, 
           label = tp185.635nm.cont.stat$p.signif,
           size = 5) +
  #plot title
  xlab("S218A - Continuous")

tp185.635nm.cont.plot <- plot.msacr1.f1(tp185.635nm.cont.plot)

tp185.635nm.cont.plot

#----
#tp185 635nm pulse ******** ----

df.tp185.635nm.pulse <- filter(df.msacr1, opsin == "tp185" & light == "635nm" &
                                 treatment2 == "pulse")
head(df.tp185.635nm.pulse)
#----
#tp185 635nm pulse stat ----
#test

tp185.635nm.pulse.stat <- compare_means(spikes ~ treatment,
                                        df.tp185.635nm.pulse,
                                        paired = TRUE,
                                        method = "t.test",
                                        p.adjust.method = "bonferroni")
tp185.635nm.pulse.stat

tp185.635nm.pulse.stat.wilcox <- compare_means(spikes ~ treatment,
                                        df.tp185.635nm.pulse,
                                        paired = TRUE,
                                        method = "wilcox.test",
                                        p.adjust.method = "bonferroni")
tp185.635nm.pulse.stat.wilcox
#----
#tp185 635nm pulse plot ----

tp185.635nm.pulse.plot <- ggplot(df.tp185.635nm.pulse, aes(x = treatment, y = spikes,
                                                           color = treatment)) +
  #x axis
  scale_x_discrete(limit = c("ramp_no_light", "ramp_635nm_pulse"),
                   labels = c("No light", "635 nm")) +
  scale_color_manual(values = c("#d04826", "lightgray")) +
  #stat
  annotate("text", x = 1.5, y = max(df.msacr1$spikes, na.rm = TRUE) + 1, 
           label = tp185.635nm.pulse.stat$p.signif,
           size = 5) +
  #plot title
  xlab("S218A - 10 Hz")

tp185.635nm.pulse.plot <- plot.msacr1.f1(tp185.635nm.pulse.plot)

tp185.635nm.pulse.plot
(tp185.550nm.cont.plot | tp185.550nm.pulse.plot | tp185.635nm.cont.plot | tp185.635nm.pulse.plot )

#summary plot ----

tp184.550nm.cont.plot + tp184.550nm.pulse.plot + tp184.635nm.cont.plot + tp184.635nm.pulse.plot +
  tp185.550nm.cont.plot + tp185.550nm.pulse.plot + tp185.635nm.cont.plot + tp185.635nm.pulse.plot +
  plot_layout(design = "1234
                        5678")

ggsave("output/figure/3e.jpg",
       plot = last_plot(),
       device = "jpg",
       width = 17,
       height = 17,
       units = "cm",
       dpi = 300)

# Intensity plot ----

#tp184 550nm intensity ******** ----
df.tp184.550nm.int <- df.msacr1 %>%
  filter(opsin %in% c("tp184"), light == "550nm", treatment == "intensity_curve") %>%
  mutate(uw_mm2 = ifelse(uw_mm2 == 0, 0.000000001, uw_mm2))

head(df.tp184.550nm.int)
glimpse(df.tp184.550nm.int)
View(df.tp184.550nm.int)

#prediction 550nm ---
pred.550nm <- data.frame(uw_mm2 = seq(min(df.tp184.550nm.int$uw_mm2)+0.0001,
                                      max(df.tp184.550nm.int$uw_mm2), 
                                      length.out=1000))
head(pred.550nm)
View(pred.550nm)
#----
#tp184 550nm intensity fit ----

tp184.550nm.fit <- drm(rel_uw_mm2 ~ uw_mm2,
                       data = df.tp184.550nm.int,
                       type = "continuous",
                       fct = llogistic())
plot(tp184.550nm.fit)

tp184.550nm.pred <-  data.frame(pred.550nm, 
                                rel_uw_mm2 = predict(tp184.550nm.fit, pred.550nm))
head(tp184.550nm.pred)
plot(tp184.550nm.pred)

#tp185 550nm intensity ******** ----

df.tp185.550nm.int <- df.msacr1 %>%
  filter(opsin %in% c("tp185"), light == "550nm", treatment == "intensity_curve") %>%
  mutate(uw_mm2 = ifelse(uw_mm2 == 0, 0.000000001, uw_mm2), 
         rel_uw_mm2 = as.numeric(rel_uw_mm2))

head(df.tp185.550nm.int)

#prediction 550nm ---
pred.550nm <- data.frame(uw_mm2 = seq(min(df.tp185.550nm.int$uw_mm2)+0.0001,
                                      max(df.tp185.550nm.int$uw_mm2), 
                                      length.out=1000))
head(pred.550nm)
#----
#tp185 550nm intensity fit ----

tp185.550nm.fit <- drm(rel_uw_mm2 ~ uw_mm2,
                       data = df.tp185.550nm.int,
                       type = "continuous",
                       fct = llogistic())
plot(tp185.550nm.fit)

tp185.550nm.pred <-  data.frame(pred.550nm, 
                                rel_uw_mm2 = predict(tp185.550nm.fit, pred.550nm))
head(tp185.550nm.pred)
plot(tp185.550nm.pred)

#combine opsins' intensity

intensity_plot <- ggplot() +
  stat_summary(data = df.tp184.550nm.int,
               aes(x = uw_mm2,
                   y = rel_uw_mm2),
               fun.data = "mean_se",
               geom = "pointrange",
               size = 0.8,
               color = "black",
               alpha = 0.5) +
  stat_summary(data = df.tp185.550nm.int,
               aes(x = uw_mm2,
                   y = rel_uw_mm2),
               fun.data = "mean_se",
               geom = "pointrange",
               size = 0.8,
               color = "darkgray",
               alpha = 0.5) +
  geom_line(data = tp184.550nm.pred,
            aes(x = uw_mm2,
                y = rel_uw_mm2),
            lwd = 0.61,
            color = "black") +
  geom_line(data = tp185.550nm.pred,
            aes(x = uw_mm2,
                y = rel_uw_mm2),
            lwd = 0.61,
            color = "darkgray") +
  #scale_x_log10(limits = c(10^-4, 10)) +
  theme_classic() +
  xlab("550 nm (uW/mm2)") +
  ylab("Firing probability")

intensity_plot <- plot.msacr1.f2(intensity_plot)

intensity_plot

#zoom
zoom_p <- ggplot() +
  stat_summary(data = df.tp184.550nm.int,
               aes(x = uw_mm2,
                   y = rel_uw_mm2),
               fun.data = "mean_se",
               geom = "pointrange",
               size = 0.3,
               color = "black",
               alpha = 0.5) +
  stat_summary(data = df.tp185.550nm.int,
               aes(x = uw_mm2,
                   y = rel_uw_mm2),
               fun.data = "mean_se",
               geom = "pointrange",
               size = 0.3,
               color = "darkgray",
               alpha = 0.5) +
  geom_line(data = tp184.550nm.pred,
            aes(x = uw_mm2,
                y = rel_uw_mm2),
            lwd = 0.61,
            color = "black") +
  geom_line(data = tp185.550nm.pred,
            aes(x = uw_mm2,
                y = rel_uw_mm2),
            lwd = 0.61,
            color = "darkgray") +
  #scale_x_log10(limits = c(10^-4, 10)) +
  theme_classic() +
  xlab("") +
  ylab("") +
  coord_cartesian(xlim = c(0, 0.4)) +
  scale_x_continuous(n.breaks = 3) +
  scale_y_continuous(n.breaks = 3)

 
zoom_p <- plot.msacr1.f2(zoom_p)

zoom_p

(intensity_plot | zoom_p)

# total

total_p <- intensity_plot +
  annotation_custom(ggplotGrob(zoom_p), xmin = 7 , xmax = 15, ymin = 0.25, ymax = 1) 

total_p

ggsave("output/figure/3c.jpg",
       plot = last_plot(),
       device = "jpg",
       width = 4,
       height = 4,
       units = "in",
       dpi = 300)

# Evoked plot ----
data_wt_vs_s218a <- read.csv("data/data2.csv")
data_wt_vs_s218a <- data_wt_vs_s218a 
head(data_wt_vs_s218a)

delta_t_p <- ggplot(data_wt_vs_s218a, aes(x = delta_t.s.,
                                          y = spike,
                                          fill = opsin,
                                          color = opsin)) +
  stat_summary(fun  = "mean",
               geom = "line",
               size = 1) +
  stat_summary(fun.data = "mean_se",
               geom = "pointrange",
               shape = 21,
               size = 1.2,
               alpha = 0.8) +
  scale_fill_manual(labels = c("WT", "S218A"),
                    values = c("black", "darkgray")) +
  scale_color_manual(labels = c("WT", "S218A"),
                     values = c("black", "darkgray")) +
  scale_y_continuous(expand = c(0, 0.03)) +
  labs(color = "") +
  xlab(expression(paste(Delta, "t (ms)"))) +
  ylab("Spike frequency") +
  theme_classic() +
  theme(axis.title.x = "element_text"(size = 15),
        axis.title.y = "element_text"(size = 15),
        axis.text.x  = "element_text"(size = 11, hjust = 0.5),
        axis.text.y  = "element_text"(size = 11),
        legend.position = "none")

ggsave("output/figure/3g.jpg",
       plot = delta_t_p,
       device = "jpg",
       width = 5,
       height = 5,
       units = "in",
       dpi = 300)
