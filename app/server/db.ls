require! {
  Bookshelf: \bookshelf
  Promise: \bookshelf/node_modules/bluebird
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
    util.collection-name t |> change-case.param-case

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
  UsersConversations
} = module.exports

# setup entity relations
export __relations =
  Alias:{}
  Auth:{}
  Conversation:{}
  Doc:{}
  Domain:{}
  Follow:{}
  Forum:{}
  Image:{}
  Message:{}
  MessagesRead:{}
  Moderation:{}
  Page:{}
  Post:{}
  Product:{}
  Purchase:{}
  Site:{}
  Subscription:{}
  Tag:{}
  TagsMessages:{}
  TagsPosts:{}
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
  Site:
    parse: (attrs) ->
      attrs.config = if attrs.config then JSON.parse attrs.config else {}
      attrs
    format: (attrs) ->
      if attrs.config
        attrs.config = JSON.stringify attrs.config
      attrs

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
