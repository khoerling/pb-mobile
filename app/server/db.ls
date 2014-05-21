require! {
  Bookshelf: \bookshelf
  Promise: \bluebird
  shared: \../shared/helpers
  \pretty-error
  \change-case
  validator
  moment
}

pe = new pretty-error!

export __tables = <[
  aliases
  auths
  conversations
  docs
  domains
  follows
  forums
  images
  messages
  messages_read
  moderations
  pages
  posts
  products
  purchases
  sites
  subscriptions
  tags
  tags_messages
  tags_posts
  thread_subscriptions
  users
  users_conversations
]>

# initialize bookshelf models and collections
export Bookshelf = Bookshelf

# connection to mysql
export Postgres = Bookshelf.initialize(
  client     : \postgresql
  debug      : process.env.DB_DEBUG    or false
  connection :
    host     : process.env.DB_HOST     or \127.0.0.1
    user     : process.env.DB_USER     or \postgres
    password : process.env.DB_PASSWORD or void
    database : process.env.DB_NAME     or \pb
)
Postgres.plugin \virtuals

# utility functions
export util =
  class-name: (t) ->
    switch t
    | \aliases             => \Alias
    | \messages_read       => \MessagesRead
    | \tags_messages       => \TagsMessages
    | \tags_posts          => \TagsPosts
    | \users_conversations => \UsersConversations
    | otherwise            => change-case.pascal-case(t).replace(/s$/, '')

  model-name: (t) ->
    tt = if t.match /IP/
      t.replace /IP/, 'Ip'
    else
      t
    change-case.camel-case tt

  collection-name: (t) ->
    tt = if t.match /IP/
      t.replace /IP/, 'Ip'
    else
      t
    "#{change-case.camel-case tt}s"

  route-name: (t) ->
    t

  json-fields: (fields) ->
    {
      parse: (attrs) ->
        for f in fields
          attrs[f] = JSON.parse attrs[f] if attrs[f]
        attrs
      format: (attrs) ->
        for f in fields
          attrs[f] = JSON.stringify attrs[f] if attrs[f]
        attrs
    }

# make Bookshelf Models for every table
for let t in __tables
  proto = {
    table-name: t,

    # default created time for new models is now
    defaults: ->
      {
        created: moment!unix!
      }

    # every model gets a validate-async method that does the promise version of a no-op
    validate-async: (-> Promise.resolve null)

    # This will delete all of a model's has-many relations before deleting itself.
    #
    # return {Promise}    resolves to true if it destroyed everything successfully
    destroy-recursively: ->
      relations = keys __relations[util.class-name @table-name]
      |> map (~> { name: it, relation: this[it]! })
      |> group-by (~> it.relation.related-data.type)
      child-relations = if relations?has-many
        relations.has-many |> map (.name)
      else
        []
      Promise.map(child-relations, (rel) ~>
        @load rel
      ).then(~>
        Promise.reduce(child-relations, ((m, rel) ~>
          @related(rel).invokeThen('destroyRecursively')
          m+1
        ), 0)
      ).then(~>
        @destroy!
      )
  }
  proto.rm-rf = proto.destroy-recursively
  module.exports[util.class-name t] = Postgres.Model.extend proto

# assign existing tables to local vars
{
  Alias
  Auth
  Conversation
  Doc
  Domain
  Follow
  Forum
  Image
  Message
  MessagesRead
  Moderation
  Page
  Post
  Product
  Purchase
  Site
  Subscription
  Tag
  TagsMessages
  TagsPosts
  User
  UsersConversations
} = module.exports

# setup entity relations
export __relations =
  Alias:
    user: ->
      @belongs-to User, \user_id
    site: ->
      @belongs-to Site, \site_id

  Auth:
    user: ->
      @belongs-to User, \user_id

  Conversation:
    site: ->
      @belongs-to Site, \site_id
    messages: ->
      @has-many Message, \conversation_id

  Doc:{}

  Domain:
    site: ->
      @belongs-to Site, \site_id

  Follow:
    site: ->
      @belongs-to Site, \site_id
    user: ->
      @belongs-to User, \user_id

  Forum:
    site: ->
      @belongs-to Site, \site_id
    posts: ->
      @has-many Post, \forum_id

  Image:
    post: ->
      @belongs-to Post, \post_id
    thread: ->
      @belongs-to Post, \thread_id

  Message:
    user: ->
      @belongs-to User, \user_id
    conversation: ->
      @belongs-to Conversation, \conversation_id
    messages-read: ->
      @has-many MessagesRead, \message_id

  MessagesRead:
    message: ->
      @belongs-to Messagee, \message_id
    user: ->
      @belongs-to User, \user_id

  Moderation:
    user: ->
      @belongs-to User, \user_id
    post: ->
      @belongs-to Post, \post_id

  Page:
    site: ->
      @belongs-to Site, \site_id

  Post:
    thread: ->
      @belongs-to Post, \thread_id
    parent: ->
      @belongs-to Post, \parent_id
    thread-posts: ->
      @has-many Post, \thread_id
    child-posts: ->
      @has-many Post, \parent_id
    user: ->
      @belongs-to User, \user_id
    forum: ->
      @belongs-to Forum, \forum_id
    images: ->
      @has-many Image, \post_id
    thread-images: ->
      @has-many Image, \thread_id

  Product: {}

  Purchase:
    user: ->
      @belongs-to User, \user_id

  Site:
    user: ->
      @belongs-to User, \user_id
    domains: ->
      @has-many Domain, \site_id
    aliases: ->
      @has-many Alias, \site_id
    conversation: ->
      @has-many Conversation, \site_id
    follows: ->
      @has-many Follow, \site_id
    forums: ->
      @has-many Forum, \site_id
    pages: ->
      @has-many Page, \site_id

  Subscription:{}
  Tag:{}
  TagsMessages:{}
  TagsPosts:{}
  User:
    aliases: ->
      @has-many Alias, \user_id
    auths: ->
      @has-many Auth, \user_id
    follows: ->
      @has-many Follow, \user_id
    messages: ->
      @has-many Message, \user_id
    conversations: ->
      @has-many Conversation, \user_id
    messages-read: ->
      @has-many MessagesRead, \user_id
    moderations: ->
      @has-many Moderation, \user_id
    posts: ->
      @has-many Post, \user_id
    purchases: ->
      @has-many Purchase, \user_id

  UsersConversations:{}

  Client:
    promos: ->
      @has-many Promo, \Client_id
    client-accounts: ->
      @has-many ClientAccount, \Client_id

  ClientAccount:
    client: ->
      @belongs-to Client, \Client_id

  Promo:
    client: ->
      @belongs-to Client, \Client_id
    campaigns: ->
      @has-many Campaign, \Promo_id
    assets: ->
      @has-many Asset, \Promo_id
    interest-tags: ->
      @belongs-to-many InterestTag, \Promo2InterestTag, \Promo_id, \InterestTag_id

  Promo2InterestTag: {}

# Keeping the extra methods separate from the relations makes introspection easier.
export __methods =
  Alias: {
  } <<< util.json-fields <[rights config]>

  Auth: {
  } <<< util.json-fields <[profile]>

  Domain: {
  } <<< util.json-fields <[config]>

  Forum: {
    threads: (opts) ->
      Post.collection!query((q) ~>
        q
          .where \forum_id, \=, @id
          .and-where \parent_id, \is, null
          .order-by \created, \desc
      ).fetch(with-related: <[user]>)
  } <<< util.json-fields <[config]>

  Site: {
  } <<< util.json-fields <[config]>

  Page: {
  } <<< util.json-fields <[config]>

  Purchase: {
  } <<< util.json-fields <[config]>

  Product: {
  } <<< util.json-fields <[config]>

  Promo:

    validate-async: ->
      # this is an example of a mostly synchronous validation function that returns a promise
      errors = []
      name = @get \name
      if typeof! name isnt \String
        errors.push [ "Name must be a string." ]
      unless name.length
        errors.push [ "Name is required." ]

      if errors.length
        Promise.resolve errors
      else
        Promise.resolve null

    virtuals:
      monthly_cost:
        get: ->
          if @relations.servers
            @relations.servers.map (-> it.get \monthly_cost) |> sum
          else
            0

# static methods
export __static =
  Promo:
    fn: -> void

for t in __tables
  c = util.class-name t
  module.exports[c].prototype <<< __relations[c]
  module.exports[c].prototype <<< __methods[c]   if __methods[c]
  module.exports[c]           <<< __static[c]    if __static[c]

# vim:fdm=indent
