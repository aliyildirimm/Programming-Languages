(define symbol-length
	(lambda (inSym)
		(if (symbol? inSym)
			(string-length (symbol->string inSym))
			0
		)
	)
)

(define sequence?
	(lambda (inSeq)
		(cond 
		( (not (list? inSeq)) #f)
		( else
			( if (null? inSeq)
				#t
				(if (eq? 1 (symbol-length (car inSeq)))
					(sequence? (cdr inSeq))
					#f
				)
			)		
		)
		)
	)
)

(define same-sequence?
	(lambda (inSeq1 inSeq2)
		(cond 
		( (not (sequence? inSeq1)) (error "inSeq1 is not a sequence.") )
		( (not (sequence? inSeq2)) (error "inSeq2 is not a sequence.") )
		( (eq? inSeq1 '())
			(if (eq? inSeq2 '())
		   		#t
				#f
			))
		( else	
			(if (eq? inSeq2 '())
				#f
				(if (eq? (car inSeq1) (car inSeq2) )
					(same-sequence? (cdr inSeq1) (cdr inSeq2))
						#f
					)
				))
		)
			
	)	
)

(define reverse-sequence
	(lambda (inSeq)
		(if (sequence? inSeq) 
			(if (null? inSeq) 
				'()
				(append (reverse-sequence (cdr inSeq)) (cons (car inSeq) '()))  
			)

			(error "inSeq is not a sequence.")
		)
	)
)

(define palindrome?
	(lambda (inSeq)
		(if(sequence? inSeq)
			(if(same-sequence? inSeq (reverse-sequence inSeq))
				#t
				#f
			)
			(error "inSeq is not a sequence.")
		)
	)
)

(define member?
	(lambda (inSym inSeq)
		(cond
		( (not (sequence? inSeq)) (error "inSeq is not a sequence."))
		( (not (eq? (symbol-length inSym) 1)) (error "inSym is not a symbol."))
		( else
			(if  (eq? inSeq '()) 
				#f
				(if (eq? inSym (car inSeq)) 
					#t
					(member? inSym (cdr inSeq))
				)	
			)
		) 
		) 
	)
)

(define remove-member
	(lambda (inSym inSeq) 
		(cond
		( (not (sequence? inSeq)) (error "inSeq is not a sequence."))
		( (not (eq? (symbol-length inSym) 1 )) (error "inSym is not symbol."))
		( (not (member? inSym inSeq)) (error "inSym is not inside of the inSeq")) 	
		( else	(if (null? inSeq) 
				'()
				(if (eq? inSym (car inSeq))
					(append (cdr inSeq))
					(cons (car inSeq) (remove-member inSym (cdr inSeq)))
				)
			)
		)
		)
	)
)
 
(define anagram?
	(lambda (inSeq1 inSeq2)
		(cond
		( (not (sequence? inSeq1))  (error "inSeq1 is not a sequence.") )
		( (not (sequence? inSeq2))  (error "inSeq2 is not a sequence.") )
		( else
			(if (null? inSeq1)	
				(if (null? inSeq2)
					#t
					#f
				)
				(if (null? inSeq2)
					 #f
                   			(if (member? (car inSeq1) inSeq2 )
                                        	(anagram? (cdr inSeq1) (remove-member (car inSeq1) inSeq2))
                                        	#f
					)
                                )

		  	 )
		)
		)			
	)	
)

(define anapoli?
	(lambda (inSeq1 inSeq2)
		(cond
		( (not (sequence? inSeq1)) (error "inSeq1 is not a sequence."))
		( (not (sequence? inSeq2)) (error "inSeq1 is not a sequence."))
		( else
			(if (palindrome? inSeq2)
               			(if (anagram? inSeq1 inSeq2)
					#t							
					#f							
				)
				#f        					
			)
		)
		)
	)
)
