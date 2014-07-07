// Generated by CoffeeScript 1.6.3
(function() {
  var GameView, GamesIndexLineView, GamesIndexView, QuestionIndexLineView, QuestionView, QuestionsIndexView, UserView, _ref, _ref1, _ref2, _ref3, _ref4, _ref5, _ref6, _ref7, _ref8,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  this.AdminView = (function(_super) {
    __extends(AdminView, _super);

    function AdminView() {
      _ref = AdminView.__super__.constructor.apply(this, arguments);
      return _ref;
    }

    AdminView.prototype.initialize = function() {
      var _this = this;
      this.game_list = new GameList();
      this.game_list.fetch();
      this.games_index_view = new GamesIndexView({
        model: this.game_list
      });
      this.question_list = all_questions;
      this.question_list.fetchOrInit();
      this.questions_index_view = new QuestionsIndexView({
        model: this.question_list
      });
      this.render();
      return this.games_index_view.on('open', function(game) {
        var game_view;
        _this.games_index_view.$el.hide();
        game_view = new GameView({
          model: game
        });
        _this.$el.append(game_view.el);
        return game_view.on('close', (function() {
          game_view.remove();
          return this.games_index_view.$el.show();
        }), _this);
      });
    };

    AdminView.prototype.render = function() {
      this.$el.html('<h2>Questions</h2>');
      this.$el.append(this.questions_index_view.el);
      return this.$el.append('<a href="#new-question" class="btn">New Question</a>');
    };

    return AdminView;

  })(Backbone.View);

  QuestionsIndexView = (function(_super) {
    __extends(QuestionsIndexView, _super);

    function QuestionsIndexView() {
      _ref1 = QuestionsIndexView.__super__.constructor.apply(this, arguments);
      return _ref1;
    }

    QuestionsIndexView.prototype.tagName = 'table';

    QuestionsIndexView.prototype.className = 'questions-index table';

    QuestionsIndexView.prototype.initialize = function() {
      this.list = this.model;
      this.render();
      return this.model.on('change', this.render, this);
    };

    QuestionsIndexView.prototype.render = function() {
      var bodyEl,
        _this = this;
      this.$el.html('');
      this.$el.append('<thead><tr><td>Creation Date</td><td>&nbsp;</td></tr></thead>');
      this.$el.append(bodyEl = $('<tbody></tbody>'));
      return this.list.each(function(question) {
        var view;
        view = new QuestionIndexLineView({
          model: question
        });
        bodyEl.append(view.el);
        return view.on('open', (function(question) {
          return this.trigger('open', question);
        }), _this);
      });
    };

    return QuestionsIndexView;

  })(Backbone.View);

  QuestionIndexLineView = (function(_super) {
    __extends(QuestionIndexLineView, _super);

    function QuestionIndexLineView() {
      _ref2 = QuestionIndexLineView.__super__.constructor.apply(this, arguments);
      return _ref2;
    }

    QuestionIndexLineView.prototype.tagName = 'tr';

    QuestionIndexLineView.prototype.events = {
      'click .delete': 'del'
    };

    QuestionIndexLineView.prototype.initialize = function() {
      this.render();
      return this.model.on('destroy', (function() {
        return this.remove();
      }), this);
    };

    QuestionIndexLineView.prototype.render = function() {
      this.$el.html('');
      this.$el.append('<td><a href="#/question/' + this.model.id + '" class="open">' + this.model.get('text') + '</a></td>');
      return this.$el.append('<td><a href="#" class="delete">delete</a></td>');
    };

    QuestionIndexLineView.prototype.open = function(e) {
      return this.trigger('open', this.model);
    };

    QuestionIndexLineView.prototype.del = function(e) {
      e.preventDefault();
      return this.model.destroy();
    };

    return QuestionIndexLineView;

  })(Backbone.View);

  QuestionView = (function(_super) {
    __extends(QuestionView, _super);

    function QuestionView() {
      _ref3 = QuestionView.__super__.constructor.apply(this, arguments);
      return _ref3;
    }

    QuestionView.prototype.tagName = 'div';

    QuestionView.prototype.events = {
      'click .save': 'takeValues'
    };

    QuestionView.prototype.initialize = function() {
      this.render();
      return this.model.on('destroy', (function() {
        return this.remove();
      }), this);
    };

    QuestionView.prototype.render = function() {
      this.$el.html($('#question-form').html());
      return this.showValues();
    };

    QuestionView.prototype.showValues = function() {
      this.$el.find('#question-text').val(this.model.get('text'));
      this.$el.find('#answer-yes-skill1').val(this.model.yAnswer().get('manipulations')['income tax']);
      this.$el.find('#answer-yes-skill2').val(this.model.yAnswer().get('manipulations')['education level']);
      this.$el.find('#answer-yes-skill3').val(this.model.yAnswer().get('manipulations')['public health']);
      this.$el.find('#answer-yes-skill4').val(this.model.yAnswer().get('manipulations')['entrepreneurship']);
      this.$el.find('#answer-yes-skill5').val(this.model.yAnswer().get('manipulations')['community art']);
      this.$el.find('#answer-yes-skill6').val(this.model.yAnswer().get('manipulations')['immigration']);
      this.$el.find('#answer-no-skill1').val(this.model.nAnswer().get('manipulations')['income tax']);
      this.$el.find('#answer-no-skill2').val(this.model.nAnswer().get('manipulations')['education level']);
      this.$el.find('#answer-no-skill3').val(this.model.nAnswer().get('manipulations')['public health']);
      this.$el.find('#answer-no-skill4').val(this.model.nAnswer().get('manipulations')['entrepreneurship']);
      this.$el.find('#answer-no-skill5').val(this.model.nAnswer().get('manipulations')['community art']);
      return this.$el.find('#answer-no-skill6').val(this.model.nAnswer().get('manipulations')['immigration']);
    };

    QuestionView.prototype.takeValues = function(e) {
      var answer, nManipulations, yManipulations;
      if (e) {
        e.preventDefault();
      }
      this.model.set({
        text: this.$el.find('#question-text').val()
      });
      this.model.save();
      yManipulations = this.model.yAnswer().get('manipulations');
      yManipulations['income tax'] = parseInt(this.$el.find('#answer-yes-skill1').val());
      yManipulations['education level'] = parseInt(this.$el.find('#answer-yes-skill2').val());
      yManipulations['public health'] = parseInt(this.$el.find('#answer-yes-skill3').val());
      yManipulations['entrepreneurship'] = parseInt(this.$el.find('#answer-yes-skill4').val());
      yManipulations['community art'] = parseInt(this.$el.find('#answer-yes-skill5').val());
      yManipulations['immigration'] = parseInt(this.$el.find('#answer-yes-skill6').val());
      answer = this.model.yAnswer();
      answer.set({
        manipulations: yManipulations
      });
      this.model.yAnswer().save();
      nManipulations = this.model.nAnswer().get('manipulations');
      nManipulations['income tax'] = parseInt(this.$el.find('#answer-no-skill1').val());
      nManipulations['education level'] = parseInt(this.$el.find('#answer-no-skill2').val());
      nManipulations['public health'] = parseInt(this.$el.find('#answer-no-skill3').val());
      nManipulations['entrepreneurship'] = parseInt(this.$el.find('#answer-no-skill4').val());
      nManipulations['community art'] = parseInt(this.$el.find('#answer-no-skill5').val());
      nManipulations['immigration'] = parseInt(this.$el.find('#answer-no-skill6').val());
      this.model.nAnswer().set({
        manipulations: nManipulations
      });
      this.model.nAnswer().save();
      return this.trigger('close');
    };

    return QuestionView;

  })(Backbone.View);

  GamesIndexView = (function(_super) {
    __extends(GamesIndexView, _super);

    function GamesIndexView() {
      _ref4 = GamesIndexView.__super__.constructor.apply(this, arguments);
      return _ref4;
    }

    GamesIndexView.prototype.tagName = 'table';

    GamesIndexView.prototype.className = 'games-index table';

    GamesIndexView.prototype.initialize = function() {
      this.game_list = this.model;
      return this.render();
    };

    GamesIndexView.prototype.render = function() {
      var bodyEl,
        _this = this;
      this.$el.html('');
      this.$el.append('<thead><tr><td>Creation Date</td><td>&nbsp;</td></tr></thead>');
      this.$el.append(bodyEl = $('<tbody></tbody>'));
      return this.game_list.each(function(game) {
        var view;
        view = new GamesIndexLineView({
          model: game
        });
        bodyEl.append(view.el);
        return view.on('open', (function(game) {
          return this.trigger('open', game);
        }), _this);
      });
    };

    return GamesIndexView;

  })(Backbone.View);

  GamesIndexLineView = (function(_super) {
    __extends(GamesIndexLineView, _super);

    function GamesIndexLineView() {
      _ref5 = GamesIndexLineView.__super__.constructor.apply(this, arguments);
      return _ref5;
    }

    GamesIndexLineView.prototype.tagName = 'tr';

    GamesIndexLineView.prototype.events = {
      'click .open': 'open',
      'click .delete': 'del'
    };

    GamesIndexLineView.prototype.initialize = function() {
      this.render();
      return this.model.on('destroy', (function() {
        return this.remove();
      }), this);
    };

    GamesIndexLineView.prototype.render = function() {
      this.$el.html('');
      this.$el.append('<td><a href="#" class="open">' + this.model.get('created_at') + '</a></td>');
      return this.$el.append('<td><a href="#" class="delete">delete</a></td>');
    };

    GamesIndexLineView.prototype.open = function(e) {
      e.preventDefault();
      return this.trigger('open', this.model);
    };

    GamesIndexLineView.prototype.del = function(e) {
      e.preventDefault();
      return this.model.destroy();
    };

    return GamesIndexLineView;

  })(Backbone.View);

  GameView = (function(_super) {
    __extends(GameView, _super);

    function GameView() {
      _ref6 = GameView.__super__.constructor.apply(this, arguments);
      return _ref6;
    }

    GameView.prototype.tagName = 'div';

    GameView.prototype.className = 'game-details';

    GameView.prototype.events = {
      'click .close': 'close'
    };

    GameView.prototype.initialize = function() {
      this.user_view = new UserView({
        model: this.model.user
      });
      this.render();
      return this.model.on('destroy', (function() {
        this.remove();
        return this.trigger('close');
      }), this);
    };

    GameView.prototype.render = function() {
      this.$el.html('');
      this.$el.append('Creation date: ' + this.model.get('created_at') + '<br/>');
      this.$el.append('User id: ' + this.model.get('user_id') + '<br/>');
      this.$el.append('<h1>User</h1>');
      return this.$el.append(this.user_view.el);
    };

    GameView.prototype.close = function() {
      return this.trigger('close');
    };

    return GameView;

  })(Backbone.View);

  UserView = (function(_super) {
    __extends(UserView, _super);

    function UserView() {
      _ref7 = UserView.__super__.constructor.apply(this, arguments);
      return _ref7;
    }

    UserView.prototype.tagName = 'div';

    UserView.prototype.className = 'user-details';

    UserView.prototype.initialize = function() {
      return this.render();
    };

    UserView.prototype.render = function() {
      this.$el.html('');
      if (!this.model) {
        return;
      }
      this.$el.append('Name: ' + this.model.get('name') + '<br/>');
      return this.$el.append('Skills: ' + this.model.get('skillSummary'));
    };

    return UserView;

  })(Backbone.View);

  this.AdminRouter = (function(_super) {
    __extends(AdminRouter, _super);

    function AdminRouter() {
      _ref8 = AdminRouter.__super__.constructor.apply(this, arguments);
      return _ref8;
    }

    AdminRouter.prototype.routes = {
      "question/:id": 'showQuestion',
      "new-question": 'newQuestion',
      "*action": 'defaultRoute'
    };

    AdminRouter.prototype._adminView = function() {
      return this.__adminview || (this.__adminview = new AdminView());
    };

    AdminRouter.prototype._questionView = function(id) {
      var list, q, view;
      list = all_questions;
      list.fetch();
      if (q = list.get(id)) {
        view = new QuestionView({
          model: q
        });
        view.on('close', (function() {
          return this.navigate('#/');
        }), this);
        return view;
      }
      return null;
    };

    AdminRouter.prototype.newQuestion = function() {
      var q;
      q = all_questions.createEmptyQuestion();
      return this.navigate('#/question/' + q.id);
    };

    AdminRouter.prototype.defaultRoute = function(action) {
      $('#admin').html('');
      return $('#admin').append(this._adminView().el);
    };

    AdminRouter.prototype.showQuestion = function(question_id) {
      var view;
      if (this.__questionView) {
        this.__questionView.remove();
      }
      if (view = this._questionView(question_id)) {
        $('#admin').html('');
        return $('#admin').append(view.el);
      }
    };

    return AdminRouter;

  })(Backbone.Router);

}).call(this);
