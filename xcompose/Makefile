.PHONY : all install

all : XCompose

XCompose : generate.lhs
	runhaskell generate.lhs > XCompose

install : XCompose
	cp XCompose ~/.XCompose
