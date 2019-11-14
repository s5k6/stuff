
> infixr 4 :-
> infixr 4 :=
>     
> data Branch
>     = String :- [Branch]
>     | String := String
>     deriving (Eq, Ord)

> instance Show Branch where
>     showsPrec _ = foldl (.) id . pp
      
> pp :: Branch -> [ShowS]
> pp (k := v) = [ key k . showString ": \"" . showString v . showString "\"\n" ]
> pp (k :- bs) = concatMap ((\b -> map ((.) $ key k) $ pp b) :: Branch -> [ShowS]) bs

> key :: String -> ShowS
> key k = showChar '<' . showString k . showString "> "


missing Stuff: ⟨⟩

> charWise xs ys
>     = zipWith (:=)
>       (map return . concat $ words xs)
>       (map return . concat $ words ys)

> name n s = "ampersand" :- [f n]
>     where
>     f [] = "semicolon" := s
>     f (x:xs) = [x] :- [f xs]
        
> mapping :: [Branch]
> mapping
>     = [ "backslash"
>         :-
>         charWise
>         "Aa Bb Cc Dd Ee Ff Gg Hh Jj Kk Ll Mm Nn Oo Pp Qq Rr Ss Tt Uu Yy Xx Zz"
>         "אα בβ Χχ Δδ ?ε Φφ Γγ ?η ?ι ?κ Λλ ?μ ?ν Ωω Ππ Ψψ ?ρ Σσ ?τ Θθ ?υ Ξξ ?ζ"
>       , "bracketleft" :- [ "bracketright" := "⟦⟧"
>                          , "apostrophe" := "‘"
>                          , "quotedbl" := "“"
>                          ]
>       , "bracketright" :- [ "apostrophe" := "’"
>                           , "quotedbl" := "”"
>                           ]
>       , "o" :- [ "o" := "°"
>                , "C" := "℃"
>                , "F" := "℉"
>                ]
>       , "s" :- [ "s" := "ß" ]
>       , "period" :- [ "period" := "…"
>                     , "space" := "∘"
>                     ]
>       , "equal" :- [ "equal" := "≡"
>                    , "less" := "≤"
>                    , "greater" := "≥"
>                    ]
>       , "quotedbl" :- charWise "aAeEiIoOuU" "äÄëËïÏöÖüÜ"
>                       ++
>                       [ "quotedbl" := "“”" ]
>       , "apostrophe" :- charWise "aAeEiIoOuU" "áÁéÉíÍóÓúÚ"
>                         ++
>                         [ "apostrophe" := "‘’" ]
>       , "asterisk" := "·"
>       , "minus" :- [ "f" := "‒" -- figure-dash
>                    , "n" := "–" -- en-dash
>                    , "m" := "—" -- em-dash
>                    , "q" := "―" -- quotation-dash
>                    , "plus" := "∓"
>                    ]
>       , "less" := "‹", "greater" := "›"
>       , "Right" :- [ "space" := "→", "Up" := "↗", "Down" := "↘"
>                    , "Left" := "↔", "Right" := "⇒" ]
>       , "Left"  :- [ "space" := "←", "Up" := "↖", "Down" := "↙"
>                    , "Left" := "⇐", "Right" := "⇔" ]
>       , "Up"    :- [ "space" := "↑", "Up" := "⇑", "Down" := "⇕"
>                    , "Left" := "↰", "Right" := "↱" ]
>       , "Down"  :- [ "space" := "↓", "Up" := "↕", "Down" := "⇓"
>                    , "Left" := "↲", "Right" := "↳" ]
>
>       , "bar" :- [ "bar" := "∥", "Right" := "↦"
>                  , "bracketleft" := "⟦", "bracketright" := "⟧"
>                  , "less" := "«", "greater" := "»"
>                  ]
>                  ++
>                  charWise "n z q r c"
>                           "ℕ ℤ ℚ ℝ ℂ"
> 
>       , "f" :- [ "a" := "∀" ]
>       , "e" :- [ "x" := "∃" ]
>       , "l" :- [ "a" := "∧"
>                , "o" := "∨"
>                , "n" := "¬"
>                , "t" := "⊤"
>                , "b" := "⊥"
>                ]
>       , "s" :- [ "e" := "∈"
>                , "u" := "∪"
>                , "U" := "⊎"
>                , "m" := "∖"
>                , "p" := "×"
>                , "i" := "∩"
>                , "0" := "∅"
>                , "less" := "⊂"
>                , "greater" := "⊃"
>                , "equal" :- [ "less" := "⊆", "greater" := "⊇" ]
>                ]
>       , "slash" :- [ "equal" :- [ "space" := "≠", "equal" := "≢" ]
>                    , "s" :- [ "less" := "⊄", "greater" := "⊅"
>                             , "equal" :- [ "less" := "⊈", "greater" := "⊉" ]
>                             , "e" := "∉"
>                             ]
>                    ]
>       , "space" := "\xA0"
>       , name "skull" "☠"
>       , name "peace" "☮"
>       , name "yes" "✓"
>       , name "no" "✗"
>       , name "bio" "☣"
>       , "semicolon" := "▷"
>       , "grave" :- modify "\x0300" "aeiou"
>       , "acute" :- modify "\x0301" "aeiou"
>       , "asciicircum" :- charWise "n 1 2 3 4 5 6 7 8 9 0"
>                                   "ⁿ ¹ ² ³ ⁴ ⁵ ⁶ ⁷ ⁸ ⁹ ⁰"
>                          ++
>                          modify "\x0302" "aeiou"
>       , "plus" :- [ "minus" := "±" ]
>       ]

> modify :: String -> String -> [Branch]
> modify cc xs = [ [x] := [x] ++ cc | x <- xs ]

> main :: IO ()
> main = print $ "Multi_key" :- mapping
