class @AdminView extends Backbone.View
  initialize: ->
    @game_list = new GameList()
    @game_list.fetch()
    # @game_list.each (g) -> g.destroy()
    # console.log @game_list.length
    # return
    @games_index_view = new GamesIndexView(model: @game_list)

    @render()

    @games_index_view.on 'open', (game) =>
      @games_index_view.$el.hide()
      game_view = new GameView(model: game)
      @$el.append game_view.el
      game_view.on 'close', (-> game_view.remove(); @games_index_view.$el.show()), this

  render: ->
    @$el.html '<h2>Games</h2>'

    @$el.append  @games_index_view.el


class GamesIndexView extends Backbone.View
  tagName: 'table'
  className: 'games-index'

  initialize: ->
    @game_list = @model
    @render()

  render: ->
    @$el.html ''
    @$el.append '<thead><tr><td>Creation Date</td><td>&nbsp;</td></tr></thead>'
    @$el.append bodyEl = $('<tbody></tbody>')

    @game_list.each (game) =>
      view = new GamesIndexLineView(model: game)
      bodyEl.append view.el
      view.on 'open', ((game) -> @trigger 'open', game), this


class GamesIndexLineView extends Backbone.View
  tagName: 'tr'

  events:
    'click .open': 'open'
    'click .delete': 'del'

  initialize: ->
    @render()

    @model.on 'destroy', (-> @remove()), this

  render: ->
    @$el.html ''
    @$el.append '<td><a href="#" class="open">'+@model.get('created_at')+'</a></td>'
    @$el.append '<td><a href="#" class="delete">delete</a></td>'
    
  open: (e) ->
    e.preventDefault()
    @trigger 'open', @model

  del: (e) ->
    e.preventDefault()
    @model.destroy()


class GameView extends Backbone.View
  tagName: 'div'
  className: 'game-details'

  events:
    'click .close': 'close'

  initialize: ->
    @user_view = new UserView(model: @model.user)
    @render()
    @model.on 'destroy', (-> @remove(); @trigger('close')), this

  render: ->
    console.log @model
    @$el.html ''
    @$el.append '<a href="#" class="close">close</a> | <a href="#" class="play">play</a><br/>'
    @$el.append 'Creation date: '+@model.get('created_at') + '<br/>'
    @$el.append 'User id: '+@model.get('user_id') + '<br/>'
    @$el.append '<h1>User</h1>'
    @$el.append @user_view.el

  close: -> @trigger 'close'


class UserView extends Backbone.View
  tagName: 'div'
  className: 'user-details'

  initialize: ->
    @render()

  render: ->
    @$el.html ''
    return if !@model
    console.log @model.attributes
    @$el.append 'Name: '+@model.get('name')+'<br/>'
    @$el.append 'Skills: '+@model.get('skillSummary')




