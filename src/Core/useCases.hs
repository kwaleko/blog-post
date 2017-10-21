module UseCases where


import Core.Types as T

createArticle :: (T.ArticleRepo m) => T.Article -> m ()
createArticle  = T.addArticle

deleteArticle :: (T.ArticleRepo m) => T.Article -> m ()
deleteArticle = T.deleteArticle

updateArticle :: (T.ArticleRepo m) => T.UpdateArticle -> m ()
updateArticle = T.updateArticle
