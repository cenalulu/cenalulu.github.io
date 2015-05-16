#! /bin/sh

title=$1
if [[ ! $title ]]
then
    echo "Please input a title for post"
    exit 
fi

title=`octopress new post "$title" `
mv $title _drafts/
filename=${title#*/_posts/}
echo "New Draft created as: _drafts/$filename"
echo "_drafts/$filename" | pbcopy  

