@blacklist = [
    'reddit app reddit'
    'user account menu'
    'reddit premium reddit'
    'reddit inc'
    'careers press'
    'comments share'
    'comments  share'
    'new comments'
    'press j'
    'press question mark'
    'comment log'
    'comments'
    'way'
    'user'
    'communities'
    'point'
    'reddit'
    'sign'
    'level'
    'gif'
    'votes'
    'feed'
    'hide report'
    'reactiongifs community'
    'entire discussion'
    'acceptance of our user agreement'
    'blog terms'
    'all rights reserved'
    'policy'
    'rest of the keyboard shortcuts'
    'login'
]


Meteor.methods
    clear_blacklist: =>
        console.log @blacklist
        for black_tag in @blacklist
            console.log 'removing', black_tag
            console.log 'count', Docs.find({tags:$in:[black_tag]}).count()

            result = Docs.update({tags:$in:[black_tag]}, {$pull:tags:black_tag}, {multi:true})
            console.log 'result', result
