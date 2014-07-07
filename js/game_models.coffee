#
# Question
#
class @Answer extends Backbone.Model
  defaults:
    text: 'Yes'
    manipulations:
      'income tax': 0
      'education level': 0
      'public health': 0
      'entrepreneurship': 0
      'community art': 0
      'immigration': 0

class @AnswerList extends Backbone.Collection
  model: Answer
  localStorage: new Backbone.LocalStorage("rpg-backbone-storage-answers")


class @Question extends Backbone.Model
  defaults:
    text: 'Question Text'

  answers: -> new AnswerList(all_answers.where(question_id: @id))

  getAnswer: (text) ->
    @answers().findWhere(text: text)

  yAnswer: ->@getAnswer('Yes')
  nAnswer: -> @getAnswer('No')

class @QuestionList extends Backbone.Collection
  model: Question
  localStorage: new Backbone.LocalStorage("rpg-backbone-storage-questions")

  fetchOrInit: ->
    @fetch()
    @_createDefaultQuestions() if @length == 0

  _createDefaultQuestions: ->
    console.log 'creating defaults questions'
    q = all_questions.create(text: 'Should we build more schools?')
    all_answers.create
      question_id: q.id
      text: 'Yes'
      manipulations:
        'income tax': 5
        'education level': 3
        'public health': 2
        'entrepreneurship': 3
        'community art': -3
        'immigration': 0
    all_answers.create
      question_id: q.id
      text: 'No'
      manipulations:
        'income tax': -3
        'education level': -4
        'public health': -5
        'entrepreneurship': -1
        'community art': +4
        'immigration': 0

    q = all_questions.create(text: 'Should we let foreigners work in the USA?')
    all_answers.create
      question_id: q.id
      text: 'Yes'
      manipulations:
        'income tax': 5
        'education level': 3
        'public health': 2
        'entrepreneurship': 3
        'community art': -3
        'immigration': 0
    all_answers.create
      question_id: q.id
      text: 'No'
      manipulations:
        'income tax': -3
        'education level': -4
        'public health': -5
        'entrepreneurship': -1
        'community art': +4
        'immigration': 0

  createEmptyQuestion: ->
    q = all_questions.create(text: 'New Question')
    all_answers.create
      question_id: q.id
      text: 'Yes'
      manipulations:
        'income tax': 0
        'education level': 0
        'public health': 0
        'entrepreneurship': 0
        'community art': 0
        'immigration': 0
    all_answers.create
      question_id: q.id
      text: 'No'
      manipulations:
        'income tax': 0
        'education level': 0
        'public health': 0
        'entrepreneurship': 0
        'community art': 0
        'immigration': 0
    return q



class @User extends Backbone.Model
  defaults:
    name: 'John Doe'

  initialize: ->
    @skills = new Backbone.Collection([
      {text: 'income tax', score: 0}
      {text: 'education level', score: 0}
      {text: 'public health', score: 0}
      {text: 'entrepreneurship', score: 0}
      {text: 'community art', score: 0}
      {text: 'immigration', score: 0}
    ])

    @skills.on 'change', (-> @syncSkills()), this

  skillsClone: -> new Backbone.Collection(@skills.map (skill) -> skill.clone())

  syncSkills: ->
    summary = @skills.map (skill) -> skill.get('text')+': '+skill.get('score')
    @set(skillSummary: summary)

class @UserList extends Backbone.Collection
  model: User
  localStorage: new Backbone.LocalStorage("rpg-backbone-storage-users")


class @Submission extends Backbone.Model

class @SubmissionList extends Backbone.Collection
  model: Submission
  localStorage: new Backbone.LocalStorage("rpg-backbone-storage-submissions")

class @Game extends Backbone.Model
  defaults: { created_at: new Date() }

  initialize: ->
    uList = new UserList()
    
    @user = uList.get @get('user_id') if @get('user_id')

    if !@user
      @user ||= uList.create()
      @set(user_id: @user.id)

    @submissions = new SubmissionList()
    @questions = all_questions

  # returns the current question object
  current_question: ->
    @nextQuestion() if !@get('current_question_id')
    @questions.get(@get('current_question_id'))

  submitAnswer: (answer) ->
    # apply the answer's manipulation values to the current user's skills
    _.each answer.get('manipulations'), (val, key, obj) =>
      if skill = @user.skills.findWhere(text: key)
        skill.set(score: parseInt(skill.get('score')) + parseInt(val))

    @submissions.add new Submission(user_cid: @user.cid, question_cid: @current_question().cid, answer_cid: answer.cid)

    # on to the net question
    @nextQuestion()

  # just sets the current_question_id to a new value
  nextQuestion: ->
    # pick next question
    q = @questions.sample()
    # abort f no question was found
    if !q
      @trigger 'no-questions'
      return
    # set current question
    @set(current_question_id: q.cid)
    # let anybody hook into this event
    @trigger 'new-question', @current_question()
    # return the question object
    @current_question()

class @GameList extends Backbone.Collection
  model: Game
  localStorage: new Backbone.LocalStorage("rpg-backbone-storage-games")


window.all_questions = new QuestionList()
window.all_questions.fetch()

window.all_answers = new AnswerList()
window.all_answers.fetch()
