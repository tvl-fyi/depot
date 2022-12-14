(ns bbbg.discord.auth
  (:require
   [bbbg.discord :as discord]
   [bbbg.util.core :as u]
   [bbbg.util.dev-secrets :refer [secret]]
   clj-time.coerce
   [clojure.spec.alpha :as s]
   [config.core :refer [env]]
   [ring.middleware.oauth2 :refer [wrap-oauth2]]))

(s/def ::client-id string?)
(s/def ::client-secret string?)
(s/def ::bbbg-guild-id string?)
(s/def ::bbbg-organizer-role string?)

(s/def ::config (s/keys :req [::client-id
                              ::client-secret
                              ::bbbg-guild-id
                              ::bbbg-organizer-role]))

;;;

(defn env->config []
  (s/assert
   ::config
   {::client-id (:discord-client-id env)
    ::client-secret (:discord-client-secret env)
    ::bbbg-guild-id (:bbbg-guild-id env "841295283564052510")
    ::bbbg-organizer-role (:bbbg-organizer-role
                           env
                           ;; TODO this might not be the right id
                           "908428000817725470")}))

(defn dev-config []
  (s/assert
   ::config
   {::client-id (secret "bbbg/discord-client-id")
    ::client-secret (secret "bbbg/discord-client-secret")
    ::bbbg-guild-id "841295283564052510"
    ::bbbg-organizer-role "908428000817725470"}))

;;;

(def access-token-url
  "https://discord.com/api/oauth2/token")

(def authorization-url
  "https://discord.com/api/oauth2/authorize")

(def revoke-url
  "https://discord.com/api/oauth2/token/revoke")

(def scopes ["guilds"
             "guilds.members.read"
             "identify"])

(defn discord-oauth-profile [{:keys [base-url] :as env}]
  {:authorize-uri authorization-url
   :access-token-uri access-token-url
   :client-id (::client-id env)
   :client-secret (::client-secret env)
   :scopes scopes
   :launch-uri "/auth/discord"
   :redirect-uri (str base-url "/auth/discord/redirect")
   :landing-uri (str base-url "/auth/success")})

(comment
  (-> "https://bbbg-staging.gws.fyi/auth/login"
      (java.net.URI/create)
      (.resolve "https://bbbg.gws.fyi/auth/discord/redirect")
      str)
  )

(defn wrap-discord-auth [handler env]
  (wrap-oauth2 handler {:discord (discord-oauth-profile env)}))

(defn check-discord-auth
  "Check that the user with the given token has the correct level of discord
  auth"
  [{::keys [bbbg-guild-id bbbg-organizer-role]} token]
  (and (some (comp #{bbbg-guild-id} :id)
             (discord/guilds token))
       (some #{bbbg-organizer-role}
             (:roles (discord/guild-member token bbbg-guild-id)))))

(comment
  (#'ring.middleware.oauth2/valid-profile?
   (discord-oauth-profile
    (dev-config)))
  )
