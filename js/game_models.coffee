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


class @Question extends Backbone.Model
  defaults:
    text: 'Question Text'
    answers: [
      new Answer()
      new Answer(text: 'No')
    ]

class @QuestionList extends Backbone.Collection
  model: Question
  localStorage: new Backbone.LocalStorage("rpg-backbone-storage")


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
  localStorage: new Backbone.LocalStorage("rpg-backbone-storage")


class @Submission extends Backbone.Model

class @SubmissionList extends Backbone.Collection
  model: Submission
  localStorage: new Backbone.LocalStorage("rpg-backbone-storage")

class @Game extends Backbone.Model
  defaults: { created_at: new Date() }

  initialize: ->
    uList = new UserList()
    
    @user = uList.get @get('user_id') if @get('user_id')

    if !@user
      @user ||= uList.create()
      @set(user_id: @user.id)

    @submissions = new SubmissionList()
    @questions = new QuestionList(@_questionData())
    # @questions.fetch();

  # returns the current question object
  current_question: ->
    @nextQuestion() if !@get('current_question_id')
    @questions.get(@get('current_question_id'))

  submitAnswer: (answer) ->
    # apply the answer's manipulation values to the current user's skills
    _.each answer.get('manipulations'), (val, key, obj) =>
      if skill = @user.skills.findWhere(text: key)
        skill.set(score: skill.get('score') + val)

    @submissions.add new Submission(user_cid: @user.cid, question_cid: @current_question().cid, answer_cid: answer.cid)

    # on to the net question
    @nextQuestion()

  # just sets the current_question_id to a new value
  nextQuestion: ->
    @set(current_question_id: @questions.sample().cid)
    # let anybody hook into this event
    @trigger 'new-question', @current_question()
    # return the question object
    @current_question()

  _questionData: ->
    [
      {
        text: 'Should we build more schools?'
        answers: [
          new Answer
            text: 'Yes'
            manipulations:
              'income tax': 5
              'education level': 3
              'public health': 2
              'entrepreneurship': 3
              'community art': -3
              'immigration': 0
          new Answer
            text: 'No'
            manipulations:
              'income tax': -3
              'education level': -4
              'public health': -5
              'entrepreneurship': -1
              'community art': +4
              'immigration': 0
        ],
      },
      {
        text: 'Should we let foreigners work in the USA?'
        answers: [
          new Answer
            text: 'Yes'
            manipulations:
              'income tax': -3
              'education level': 1
              'public health': 1
              'entrepreneurship': 3
              'community art': 2
              'immigration': 5
          new Answer
            text: 'No'
            manipulations:
              'income tax': 2
              'education level': -1
              'public health': -1
              'entrepreneurship': -3
              'community art': -2
              'immigration': -4
        ]
      }
    ]

class @GameList extends Backbone.Collection
  model: Game
  localStorage: new Backbone.LocalStorage("rpg-backbone-storage")

    
