;; -*- eval: (rainbow-mode) -*-
(ns bbbg.styles
  (:require
   [garden.color :as color]
   [garden.compiler :refer [compile-css]]
   [garden.def :refer [defstyles]]
   [garden.selectors
    :refer [& active attr= descendant focus hover nth-child]]
   [garden.stylesheet :refer [at-media]]
   [garden.units :refer [px]]))

(def black "#342e37")

(def silver "#f9fafb")

(def gray "#aaa")

(def gray-light "#ddd")

(def purple "#837aff")

(def red "#c42348")

(def orange "#fa824c")

(def yellow "#FACB0F")

(def blue "#026fb1")

(def green "#87E24B")

(def contextual-colors
  {:success green
   :info blue
   :warning yellow
   :error red})

;;;

(def content-width (px 1200))
(def mobile-width (px 480))

(defn desktop [& rules]
  (at-media
   {:screen true
    :min-width content-width}
   [:& rules]))

(defn mobile [& rules]
  (at-media
   {:screen true
    :max-width mobile-width}
   [:& rules]))

(defn not-mobile [& rules]
  (at-media
   {:screen true
    :min-width mobile-width}
   [:& rules]))


;;;

(defstyles global-nav
  [:.global-nav
   {:background-color silver}

   [:>ul
    {:display :flex
     :flex-direction :row
     :list-style :none}

    (desktop
     {:width content-width
      :margin "0 auto"})]

   [:a (descendant :.link-form (attr= "type" "submit"))
    {:padding "1rem 1.5rem"
     :display :block
     :color black
     :text-decoration :none}

    [(& hover)
     {:color blue}]]

   [:li.active
    {:font-weight "bold"
     :border-bottom [["1px" "solid" black]]}]]

  [:.spacer
   {:flex 1}])

(def link-conditional-styles
  (list
   [(& hover) (& active)
    {:text-decoration :underline}]
   [(& active)
    {:color purple}]))

(defstyles link-form
  [:form.link-form
   {:margin 0}
   [(attr= "type" "submit")
    {:background "none"
     :border "none"
     :padding 0
     :color blue
     :text-decoration :none
     :cursor :pointer}
    link-conditional-styles]])

(defstyles search-form
  [:.search-form
   {:display :flex
    :flex-direction :row
    :width "100%"}

   [:>*+*
    {:margin-left "0.75rem"}]

   [:input
    {:flex 1}]

   [(attr= "type" "submit")
    {:flex 0}]])

(defstyles forms
  (let [text-input-types
        #{"date"
          "datetime-local"
          "email"
          "month"
          "number"
          "password"
          "search"
          "tel"
          "text"
          "time"
          "url"
          "week"}
        each-text-type (fn [& rules]
                         (into
                          []
                          (concat
                           (map (comp & (partial attr= "type"))
                                text-input-types)
                           rules)))]
    (each-text-type
     {:width "100%"
      :display "block"
      :padding "0.6rem 0.75rem"
      :border [["1px" "solid" gray-light]]
      :border-radius "3px"
      :box-shadow [["inset" 0 "1px" "5px" "rgba(0,0,0,0.075)"]]
      :transition "border-color 150ms"
      :background "none"}
     [(& focus)
      {:outline "none"
       :border-color purple}]))

  [(attr= "type" "submit") :button :.button
   {:background-color (color/lighten blue 30)
    :padding "0.6rem 0.75rem"
    :border-radius "3px"
    :border [[(px 1) "solid" (color/lighten blue 30)]]
    :cursor :pointer
    :display :inline-block}

   [(& hover)
    {:border-color blue
     :text-decoration :none
     :box-shadow [[0 "1px" "5px" "rgba(0,0,0,0.075)"]]}
    [(:a &)
     {:text-decoration :none}]]

   [(& active)
    {:background-color blue
     :color :white
     :box-shadow :none}
    [(& :a)
     {:text-decoration :none}]]

   (for [[context color] contextual-colors]
     [(& (keyword (str "." (name context))))
      {:background-color (color/lighten color 30)
       :border-color (color/lighten color 30)
       :color black}

      [(& hover)
       {:border-color color}]])]

  [:label
   {:font-weight 600
    :width "100%"}

   [:input
    {:font-weight "initial"
     :margin-top "0.3rem"}]]

  [:.form-group
   {:display :flex
    :margin-bottom "0.8rem"
    :flex-direction :column}

   [(attr= "type" "submit")
    {:text-align :right
     :align-self :flex-end}]])

(defstyles tables
  [:table
   {:width "100%"
    :border-collapse "collapse"}]

  [:th
   {:text-align "left"}]

  [:td :th
   {:padding "0.75rem 1rem"
    :border-spacing 0
    :border "none"}]

  [:tr
   {:border-spacing 0
    :border "none"}
   [(& (nth-child :even))
    {:background-color silver}]])

(defstyles flash
  [:.flash-messages
   {:max-width "800px"
    :margin "1rem auto"}

   (at-media
    {:screen true
     :max-width "800px"}
    [:&
     {:margin-left "1rem"
      :margin-right "1rem"}])]

  [:.flash-message
   {:padding "1rem 1.5rem"
    :border "1px solid"
    :margin-bottom "1rem"}]

  (for [[context color] contextual-colors]
    [(& (keyword (str ".flash-" (name context))))
     {:border-color color
      :background-color (color/lighten color 30)
      :border-radius "3px"}]))

(defstyles home-page
  [:.home-page
   {:display :flex
    :flex 1
    :justify-content :center
    :align-items :center}
   [:.signup-form-link
    {:display :block
     :border [["1px" :solid blue]]
     :border-radius "3px"
     :color black
     :font-size "2rem"
     :background-color (color/lighten blue 50)
     :margin-left "auto"
     :margin-right "auto"
     :padding "2rem"}
    (desktop
     {:padding "5rem"
      :margin-left 0
      :margin-right 0})
    [(& hover) (& active)
     {:text-decoration :none}]
    [(& active)
     {:background-color (color/lighten blue 30)}]]])

(defstyles signup-page
  [:.signup-page
   {:margin "1rem"}
   (desktop
    {:width content-width
     :margin "1rem auto"})]

  [:#signup-form
   {:display :flex
    :flex-direction :row
    :width "100%"}

   [:*
    {:flex 1}]

   [:*+*
    {:margin-left "1rem"}]

   [(attr= "type" "submit")
    {:flex 0}]]

  [:#attendees-list
   {:list-style "none"
    :overflow-y "auto"
    :height "calc(100vh - 8.32425rem)"}

   [:li
    {:padding "0.75rem 1rem"
     :margin "0.35rem 0"
     :border-radius "3px"
     :background-color silver}]]

  [:.no-attendees
   {:text-align "center"
    :margin-top "6rem"}

   [:.button
    {:margin-top "0.5rem"}]]

  [:.hidden
   {:display :none}])

(defstyles attendees
  [:.attendee-checks-form
   {:max-width "340px"
    :margin-left "auto"
    :margin-right "auto"}]

  [:.attendees
   (mobile
    {:display :block}

    [:thead {:display :none}]
    [:tbody :tr :td
     {:display :block}]

    [:tr
     {:background-color silver
      :padding "0.5rem 0.8rem"
      :margin-bottom "1rem"
      :border-radius "3px"}]
    [:td {:padding "0.2rem 0"}]

    [:.attendee-name
     {:font-weight "bold"
      :margin-bottom "0.9rem"}])

   (not-mobile
    [:.mobile-label
     {:display :none}])])

(defstyles events
  [:.events-list
   {:margin-top "1rem"}

   [:li
    {:margin-bottom "1rem"}]])

(defstyles styles
  forms
  tables
  global-nav
  link-form
  search-form
  flash
  home-page
  signup-page
  attendees
  events

  [:body
   {:color black}]

  [:.content
   {:display :flex
    :flex-direction :column
    :height "100%"
    :width "100%"}]

  [:.page
   {:margin-top "1rem"
    :margin-left "1rem"
    :margin-right "1rem"}

   (desktop
    {:width content-width
     :margin-left "auto"
     :margin-right "auto"})]

  [:.page-header
   {:display :flex
    :flex-wrap :wrap
    :padding-bottom "0.7rem"
    :margin-bottom "1rem"
    :border-bottom [["1px" "solid" silver]]
    :align-items :center}

   [:*+*
    {:margin-left "0.5rem"}]

   [:form
    {:margin-block-end 0}]]

  [(attr= "role" "button")
   {:cursor :pointer}]

  [:a {:color blue
       :text-decoration :none}
   link-conditional-styles])

(def stylesheet
  (compile-css styles))
