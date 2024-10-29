// SYNTAX TEST "C3.sublime-syntax"

/**
 * Comment Tests
 */

// comment
// <- comment.line.double-slash.c3 punctuation.definition.comment.c3
 // <- comment.line.double-slash.c3 punctuation.definition.comment.c3
//^^^^^^^^ comment.line.double-slash.c3 - punctuation

    /**/
//  ^^ comment.block.c3 punctuation.definition.comment.begin.c3
//    ^^ comment.block.c3 punctuation.definition.comment.end.c3

    /*/**/*/
//  ^^ comment.block.c3 punctuation.definition.comment.begin.c3 - coment comment
//    ^^ comment.block.c3 comment.block.c3 punctuation.definition.comment.begin.c3
//      ^^ comment.block.c3 comment.block.c3 punctuation.definition.comment.end.c3
//        ^^ comment.block.c3 punctuation.definition.comment.end.c3 - coment comment
//          ^ - comment

    /**
// ^ - comment
//  ^^^ comment.block.documentation.c3 punctuation.definition.comment.begin.c3
//     ^ comment.block.documentation.c3 - punctuation
     */
// <- comment.block.documentation.c3
//   ^^ comment.block.documentation.c3 punctuation.definition.comment.end.c3
//     ^ - comment

    <* */ *>
//  ^^^^^^^^ comment.block.documentation.c3
//  ^^ punctuation.definition.comment.begin.c3
//        ^^ punctuation.definition.comment.end.c3
