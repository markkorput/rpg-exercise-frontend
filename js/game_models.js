// Generated by CoffeeScript 1.6.3
(function() {
  var _ref, _ref1, _ref2, _ref3, _ref4, _ref5, _ref6, _ref7, _ref8,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  this.Answer = (function(_super) {
    __extends(Answer, _super);

    function Answer() {
      _ref = Answer.__super__.constructor.apply(this, arguments);
      return _ref;
    }

    Answer.prototype.defaults = {
      text: 'Yes',
      manipulations: {
        'income tax': 0,
        'education level': 0,
        'public health': 0,
        'entrepreneurship': 0,
        'community art': 0,
        'immigration': 0
      }
    };

    return Answer;

  })(Backbone.Model);

  this.Question = (function(_super) {
    __extends(Question, _super);

    function Question() {
      _ref1 = Question.__super__.constructor.apply(this, arguments);
      return _ref1;
    }

    Question.prototype.defaults = {
      text: 'Question Text',
      answers: [
        new Answer(), new Answer({
          text: 'No'
        })
      ]
    };

    return Question;

  })(Backbone.Model);

  this.QuestionList = (function(_super) {
    __extends(QuestionList, _super);

    function QuestionList() {
      _ref2 = QuestionList.__super__.constructor.apply(this, arguments);
      return _ref2;
    }

    QuestionList.prototype.model = Question;

    QuestionList.prototype.localStorage = new Backbone.LocalStorage("rpg-backbone-storage");

    return QuestionList;

  })(Backbone.Collection);

  this.User = (function(_super) {
    __extends(User, _super);

    function User() {
      _ref3 = User.__super__.constructor.apply(this, arguments);
      return _ref3;
    }

    User.prototype.defaults = {
      name: 'John Doe'
    };

    User.prototype.initialize = function() {
      this.skills = new Backbone.Collection([
        {
          text: 'income tax',
          score: 0
        }, {
          text: 'education level',
          score: 0
        }, {
          text: 'public health',
          score: 0
        }, {
          text: 'entrepreneurship',
          score: 0
        }, {
          text: 'community art',
          score: 0
        }, {
          text: 'immigration',
          score: 0
        }
      ]);
      return this.skills.on('change', (function() {
        return this.syncSkills();
      }), this);
    };

    User.prototype.skillsClone = function() {
      return new Backbone.Collection(this.skills.map(function(skill) {
        return skill.clone();
      }));
    };

    User.prototype.syncSkills = function() {
      var summary;
      summary = this.skills.map(function(skill) {
        return skill.get('text') + ': ' + skill.get('score');
      });
      return this.set({
        skillSummary: summary
      });
    };

    return User;

  })(Backbone.Model);

  this.UserList = (function(_super) {
    __extends(UserList, _super);

    function UserList() {
      _ref4 = UserList.__super__.constructor.apply(this, arguments);
      return _ref4;
    }

    UserList.prototype.model = User;

    UserList.prototype.localStorage = new Backbone.LocalStorage("rpg-backbone-storage");

    return UserList;

  })(Backbone.Collection);

  this.Submission = (function(_super) {
    __extends(Submission, _super);

    function Submission() {
      _ref5 = Submission.__super__.constructor.apply(this, arguments);
      return _ref5;
    }

    return Submission;

  })(Backbone.Model);

  this.SubmissionList = (function(_super) {
    __extends(SubmissionList, _super);

    function SubmissionList() {
      _ref6 = SubmissionList.__super__.constructor.apply(this, arguments);
      return _ref6;
    }

    SubmissionList.prototype.model = Submission;

    SubmissionList.prototype.localStorage = new Backbone.LocalStorage("rpg-backbone-storage");

    return SubmissionList;

  })(Backbone.Collection);

  this.Game = (function(_super) {
    __extends(Game, _super);

    function Game() {
      _ref7 = Game.__super__.constructor.apply(this, arguments);
      return _ref7;
    }

    Game.prototype.defaults = {
      created_at: new Date()
    };

    Game.prototype.initialize = function() {
      var uList;
      uList = new UserList();
      if (this.get('user_id')) {
        this.user = uList.get(this.get('user_id'));
      }
      if (!this.user) {
        this.user || (this.user = uList.create());
        this.set({
          user_id: this.user.id
        });
      }
      this.submissions = new SubmissionList();
      return this.questions = new QuestionList(this._questionData());
    };

    Game.prototype.current_question = function() {
      if (!this.get('current_question_id')) {
        this.nextQuestion();
      }
      return this.questions.get(this.get('current_question_id'));
    };

    Game.prototype.submitAnswer = function(answer) {
      var _this = this;
      _.each(answer.get('manipulations'), function(val, key, obj) {
        var skill;
        if (skill = _this.user.skills.findWhere({
          text: key
        })) {
          return skill.set({
            score: skill.get('score') + val
          });
        }
      });
      this.submissions.add(new Submission({
        user_cid: this.user.cid,
        question_cid: this.current_question().cid,
        answer_cid: answer.cid
      }));
      return this.nextQuestion();
    };

    Game.prototype.nextQuestion = function() {
      this.set({
        current_question_id: this.questions.sample().cid
      });
      this.trigger('new-question', this.current_question());
      return this.current_question();
    };

    Game.prototype._questionData = function() {
      return [
        {
          text: 'Should we build more schools?',
          answers: [
            new Answer({
              text: 'Yes',
              manipulations: {
                'income tax': 5,
                'education level': 3,
                'public health': 2,
                'entrepreneurship': 3,
                'community art': -3,
                'immigration': 0
              }
            }), new Answer({
              text: 'No',
              manipulations: {
                'income tax': -3,
                'education level': -4,
                'public health': -5,
                'entrepreneurship': -1,
                'community art': +4,
                'immigration': 0
              }
            })
          ]
        }, {
          text: 'Should we let foreigners work in the USA?',
          answers: [
            new Answer({
              text: 'Yes',
              manipulations: {
                'income tax': -3,
                'education level': 1,
                'public health': 1,
                'entrepreneurship': 3,
                'community art': 2,
                'immigration': 5
              }
            }), new Answer({
              text: 'No',
              manipulations: {
                'income tax': 2,
                'education level': -1,
                'public health': -1,
                'entrepreneurship': -3,
                'community art': -2,
                'immigration': -4
              }
            })
          ]
        }
      ];
    };

    return Game;

  })(Backbone.Model);

  this.GameList = (function(_super) {
    __extends(GameList, _super);

    function GameList() {
      _ref8 = GameList.__super__.constructor.apply(this, arguments);
      return _ref8;
    }

    GameList.prototype.model = Game;

    GameList.prototype.localStorage = new Backbone.LocalStorage("rpg-backbone-storage");

    return GameList;

  })(Backbone.Collection);

}).call(this);
