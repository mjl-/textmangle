Textmangle: module
{
	PATH:	con "/dis/lib/textmangle.dis";

	dflag:	int;

	init:	fn();


	Descr: adt {
		name:	string;
		s:	ref Mark;  # no Head
	};

	Mark: adt {
		pick {
		Seq =>  
			l:	cyclic list of ref Mark;
		Head =>
			level:	int;
			s:	string;
		Quote =>
			m:	ref Mark;
		Text => 
			s:	string;
		List => 
			l:	cyclic list of ref Mark;  # either Text or Seq
		Descr =>
			l:	cyclic list of ref Descr;
		}
	};


	parse:	fn(l: list of string): ref Mark.Seq;
	parseseq:	fn(l: list of string, allowhead: int): ref Mark.Seq;

	totext:	fn(m: ref Mark): string;
	tohtml:	fn(m: ref Mark): string;
	tohtmlpre:	fn(m: ref Mark): string;
	totroff:	fn(m: ref Mark): string;
	tolatex:	fn(m: ref Mark): string;

	toc:	fn(m: ref Mark): list of ref Mark.Head;

	read:	fn(fd: ref Sys->FD): (list of string, string);
};
