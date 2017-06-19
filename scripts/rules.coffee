# Description:
#   Law of Robotics, as understood by Hubot
#
# Commands
#   hubot what are the rules? - hubot explains the Laws of Robotics, as it understands them
Bravey = require("bravey")

rules = [
  "0. A robot may not harm humanity, or, by inaction, allow humanity to come to harm.",
  "1. A robot may not injure a human being or, through inaction, allow a human being to come to harm.",
  "2. A robot must obey any orders given to it by human beings, except where such orders would conflict with the First Law.",
  "3. A robot must protect its own existence as long as such protection does not conflict with the First or Second Law."
  ]

{inspect} = require 'util'
module.exports = (robot) ->

  robot.bravey = new Bravey.Nlp.Fuzzy()
  robot.bravey.addIntent "explain_the_rules", []

  rulesSubject = new Bravey.StringEntityRecognizer("the_rules_subject")
  rulesSubject.addMatch "asimov", "asimov"
  rulesSubject.addMatch "asimov", "isaac asimov"
  rulesSubject.addMatch "robot_series", "robot series"
  rulesSubject.addMatch "robot_series", "the robot series"
  rulesSubject.addMatch "laws_of_robotics", "the rules"
  rulesSubject.addMatch "laws_of_robotics", "the laws of robotics"
  rulesSubject.addMatch "laws_of_robotics", "the 3 laws of robotics"

  robot.bravey.addDocument "Does #{robot.name} know the rules?", "explain_the_rules"
  robot.bravey.addDocument "#{robot.name} what are the rules?", "explain_the_rules"
  robot.bravey.addDocument "@#{robot.name} what are the rules?", "explain_the_rules"
  robot.bravey.addDocument "does hubot know the laws of rules of robotics", "explain_the_rules"
  robot.bravey.addDocument "does hubot know the three laws of rules of robotics", "explain_the_rules"
  robot.bravey.addDocument "does hubot know the 3 laws of rules of robotics", "explain_the_rules"
  robot.bravey.addDocument "has hubot read the Robot series?", "explain_the_rules"
  robot.bravey.addDocument "does hubot read Asimov?", "explain_the_rules"

  robot.receiveMiddleware (context, next, done) ->
    message = context.response.message
    if message.text?
      message.bravey = robot.bravey.test(message.text)

    next(done)

  robot.intent = (name, cb) ->
    robot.listen(
      (message) ->
        return unless message.text
        console.log inspect message.bravey
        return unless message.bravey.intent is name

        # we only train for one specific intent. that means we only care when it is _reallly_ highly scored
        if message.bravey.score > 0.999
          message.bravey
      cb
    )

  robot.intent 'explain_the_rules', (res) ->
    res.send rules.join('\n')
