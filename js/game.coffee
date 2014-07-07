#
# GameBoardView
#
class @GameView extends Backbone.View
  initialize: ->
    # init logic
    @admin_view = new AdminView()

    games = new GameList()
    # games.fetch()
    @game = games.create({}) # if games.length < 1

    @game_states = new Backbone.Collection([@getCurrentState()])

    @render()
    @$el.hide()

    # create UI
    @game_ui = new GameUi()
    @game_visuals = new GameVisuals(game_states: @game_states)

    # setup event hooks
    yes_func = (-> 
      @game_visuals.answerYesTween().start().onComplete =>
        @trigger 'answer', @getAnswer('yes')
    )
    no_func = (-> 
      @game_visuals.answerNoTween().start().onComplete =>
        @trigger 'answer', @getAnswer('no')
    )

    @game_ui.on 'answer-yes', yes_func, this
    @game_ui.on 'answer-no', no_func, this
    @game_ui.on 'toggle-stats', (-> @$el.toggle()), this
    @game_visuals.on 'answer-yes', yes_func, this
    @game_visuals.on 'answer-no', no_func, this

    @on 'answer', ((answer) -> @game.submitAnswer(answer)), this
    @game.on 'change', @renderGame, this
    @game.on 'change', @renderStats, this
    @game.user.on 'change', @renderStats, this
    @game.submissions.on 'change', @renderStats, this
    @game.submissions.on 'add', (-> @game_states.add([@getCurrentState()])), this
    @game.on 'new-question', ((question) -> @game_visuals.showQuestion(question) ), this 

    @on 'answer', =>
      @game.save()
      # console.log @game.user
      @game.user.save()
    @game.nextQuestion()

  # helpers
  game_el: -> @$el.find('#current-question')
  stats_el: -> @$el.find('#game-stats')
  getAnswer: (txt) -> _.find @game.current_question().get('answers') || [], (answer) -> answer.get('text').toLowerCase() == txt.toLowerCase()
  getCurrentState: -> new Backbone.Model number_of_answers: @game.submissions.length, skills : @game.user.skillsClone()

  # renderers
  render: ->
    @$el.html '<h1>Next Question</h1><div id="current-question"></div><h1>Game Stats</h1><ul id="game-stats"></ul>'
    @$el.append @admin_view.render().el
    
    @renderGame()
    @renderStats()
    this

  renderGame: ->
    @game_el().html ''

    if q = @game.current_question()
      @game_el().append('<h2>'+q.get('text')+'</h2>')
      _.each q.get('answers'), (answer) =>
        button = $('<button>'+answer.get('text')+'</button>')
        button.on 'click', (event) =>
          @trigger('answer', answer)

        @game_el().append(button)

  renderStats: ->
    @stats_el().html ''

    state = @getCurrentState()

    # user and scores
    @stats_el().append('<li>User: '+@game.user.get('name')+'</li>') if @game.user

    # progress 
    @stats_el().append('<li>Questions answered: '+state.get('number_of_answers')+'</li>') 

    # skills
    skills_el = $('<ul></ul>')
    (state.get('skills') || new Backbone.Collection).each (skill) -> skills_el.append('<li>'+skill.get('text')+': '+skill.get('score')+'</li>')
    skills_line = $('<li></li>')
    skills_line.append(skills_el)
    @stats_el().append(skills_line)

#
# Questions
#

class QuestionListView extends Backbone.View
  tagName: "ul"
  className: "questions-list"

  initialize: ->
    @questions = new QuestionList;
    @questions.fetch();

  render: ->
    @$el.html '<h1>Questions</h1>'
    @questions.each (question) => 
      answers = _.map(question.get('answers') || [], (answer) -> answer.get('text'))
      @$el.append('<li>'+question.get('text')+' ('+answers.join(', ')+')</li>')
    this

#
# User
#

class UserListView extends Backbone.View
  tagName: "ul"
  className: "users-list"

  initialize: ->
    @users = new UserList;
    @users.fetch();

  render: ->
    @$el.html '<h1>Users</h1>'
    @users.each (user) => 
      @$el.append('<li>Name: '+user.get('name')+'</li>')

      skills_el = $('<ul></ul>')
      user.skills.each (skill) -> skills_el.append('<li>'+skill.get('text')+': '+skill.get('score')+'</li>')
      skills_line = $('<li></li>')
      skills_line.append(skills_el)
      @$el.append(skills_line)

    this



#
# Game
#

class GameListView extends Backbone.View
  tagName: "ul"
  className: "games-list"

  initialize: ->
    @games = new GameList;
    @games.fetch();

  render: ->
    @$el.html '<h1>Games</h1>'
    @games.each (game) => 
      @$el.append('<li>Creation Date: '+game.get('created_at')+'</li>')

    this


class AdminView extends Backbone.View
  tagName: 'div'
  className: 'admin-info'

  initialize: ->
    @games_view = new GameListView()
    @users_view = new UserListView()
    @questions_view = new QuestionListView()
    @render()
    @users_view.users.on 'change', @render, this

  render: ->
    @$el.html ''
    @$el.append(@games_view.render().el)
    @$el.append(@users_view.render().el)
    @$el.append(@questions_view.render().el)
    this