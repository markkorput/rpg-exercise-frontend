class @AdminView extends Backbone.View
  initialize: ->
    @game_list = new GameList()
    @game_list.fetch()
    # @game_list.each (g) -> g.destroy()
    # console.log @game_list.length
    # return
    @games_index_view = new GamesIndexView(model: @game_list)

    @question_list = new QuestionList()
    @question_list.fetch()
    @questions_index_view = new QuestionsIndexView(model: @question_list)

    @render()

    @games_index_view.on 'open', (game) =>
      @games_index_view.$el.hide()
      game_view = new GameView(model: game)
      @$el.append game_view.el
      game_view.on 'close', (-> game_view.remove(); @games_index_view.$el.show()), this

  render: ->
    @$el.html '<h2>Questions</h2>'
    @$el.append @questions_index_view.el
    @$el.append '<h2>Games</h2>'
    @$el.append  @games_index_view.el

#
# Questions views
#

class QuestionsIndexView extends Backbone.View
  tagName: 'table'
  className: 'questions-index table'

  initialize: ->
    @list = @model
    @render()

    @model.on 'change', @render, this

  render: ->
    @$el.html ''
    @$el.append '<thead><tr><td>Creation Date</td><td>&nbsp;</td></tr></thead>'
    @$el.append bodyEl = $('<tbody></tbody>')

    @list.each (question) =>
      view = new QuestionIndexLineView(model: question)
      bodyEl.append view.el
      view.on 'open', ((question) -> @trigger 'open', question), this


class QuestionIndexLineView extends Backbone.View
  tagName: 'tr'

  events:
    # 'click .open': 'open'
    'click .delete': 'del'

  initialize: ->
    @render()

    @model.on 'destroy', (-> @remove()), this

  render: ->
    @$el.html ''
    @$el.append '<td><a href="#/question/'+@model.id+'" class="open">'+@model.get('text')+'</a></td>'
    @$el.append '<td><a href="#/question/'+@model.id+'" class="delete">delete</a></td>'
    
  open: (e) ->
    # e.preventDefault()
    @trigger 'open', @model

  del: (e) ->
    e.preventDefault()
    @model.destroy()

class QuestionView extends Backbone.View
  tagName: 'div'

  events:
    'click .save': 'takeValues'

  initialize: ->
    @render()
    @model.on 'destroy', (-> @remove()), this

  render: ->
    @$el.html $('#question-form').html()
    @showValues()

  showValues: ->
    @$el.find('#question-text').val @model.get('text')
    @$el.find('#answer-yes-skill1').val @model.yAnswer().get('manipulations')['income tax']
    @$el.find('#answer-yes-skill2').val @model.yAnswer().get('manipulations')['education level']
    @$el.find('#answer-yes-skill3').val @model.yAnswer().get('manipulations')['public health']
    @$el.find('#answer-yes-skill4').val @model.yAnswer().get('manipulations')['entrepreneurship']
    @$el.find('#answer-yes-skill5').val @model.yAnswer().get('manipulations')['community art']
    @$el.find('#answer-yes-skill6').val @model.yAnswer().get('manipulations')['immigration']
    @$el.find('#answer-no-skill1').val @model.nAnswer().get('manipulations')['income tax']
    @$el.find('#answer-no-skill2').val @model.nAnswer().get('manipulations')['education level']
    @$el.find('#answer-no-skill3').val @model.nAnswer().get('manipulations')['public health']
    @$el.find('#answer-no-skill4').val @model.nAnswer().get('manipulations')['entrepreneurship']
    @$el.find('#answer-no-skill5').val @model.nAnswer().get('manipulations')['community art']
    @$el.find('#answer-no-skill6').val @model.nAnswer().get('manipulations')['immigration']

  takeValues: (e) ->
    e.preventDefault() if e

    @model.set text: @$el.find('#question-text').val()
    @model.save()

    yManipulations = @model.yAnswer().get('manipulations')
    
    yManipulations['income tax'] = @$el.find('#answer-yes-skill1')
    yManipulations['education level'] = @$el.find('#answer-yes-skill2')
    yManipulations['public health'] = @$el.find('#answer-yes-skill3')
    yManipulations['entrepreneurship'] = @$el.find('#answer-yes-skill4')
    yManipulations['community art'] = @$el.find('#answer-yes-skill5')
    yManipulations['immigration'] = @$el.find('#answer-yes-skill6')

    @model.yAnswer().set(manipulations: yManipulations)
    @model.yAnswer().save()

    nManipulations = @model.nAnswer().get('manipulations')
    nManipulations['income tax'] = @$el.find('#answer-no-skill1')
    nManipulations['education level'] = @$el.find('#answer-no-skill2')
    nManipulations['public health'] = @$el.find('#answer-no-skill3')
    nManipulations['entrepreneurship'] = @$el.find('#answer-no-skill4')
    nManipulations['community art'] = @$el.find('#answer-no-skill5')
    nManipulations['immigration'] = @$el.find('#answer-no-skill6')
    
    @model.nAnswer().get(manipulations: nManipulations)
    @model.nAnswer().save()
    
    @trigger 'close'



#
# Games views
#

class GamesIndexView extends Backbone.View
  tagName: 'table'
  className: 'games-index table'

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




class @AdminRouter extends Backbone.Router
  routes:
    "question/:id": 'showQuestion'
    "*action": 'defaultRoute'
  
  _adminView: -> @__adminview ||= new AdminView()
  _questionView: (id) ->
    list = new QuestionList()
    list.fetch()

    if q = list.get(id)
      view = new QuestionView(model: q)
      view.on 'close', (-> @navigate('#/')), this
      return view

    return null

  defaultRoute: (action) ->
    $('#admin').html ''
    $('#admin').append @_adminView().el

  showQuestion: (question_id) ->
    @__questionView.remove() if @__questionView
    if view = @_questionView(question_id)
      $('#admin').html ''
      $('#admin').append view.el
