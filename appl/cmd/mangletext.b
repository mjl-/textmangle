implement Mangletext;

include "sys.m";
	sys: Sys;
	sprint: import sys;
include "draw.m";
include "arg.m";
include "bufio.m";
	bufio: Bufio;
	Iobuf: import bufio;
include "lists.m";
	lists: Lists;
include "string.m";
	str: String;
include "textmangle.m";
	textmangle: Textmangle;

Mangletext: module {
	init:	fn(nil: ref Draw->Context, args: list of string);
};


dflag: int;
lflag: int;
format := "text";
formats := array[] of {"text", "html", "htmlpre", "troff", "latex"};

init(nil: ref Draw->Context, args: list of string)
{
	sys = load Sys Sys->PATH;
	arg := load Arg Arg->PATH;
	bufio = load Bufio Bufio->PATH;
	lists = load Lists Lists->PATH;
	str = load String String->PATH;
	textmangle = load Textmangle Textmangle->PATH;
	textmangle->init();

	arg->init(args);
	arg->setusage(arg->progname()+" [-d] [-l] [-f text|html|htmlpre|troff|latex]");
	while((c := arg->opt()) != 0)
		case c {
		'd' =>	dflag++;
			if(dflag > 1)
				textmangle->dflag++;
		'f' =>	format = arg->earg();
			if(!isformat(format))
				arg->usage();
		'l' =>	lflag++;
		* =>	arg->usage();
		}
	args = arg->argv();
	if(len args != 0)
		arg->usage();

	(l, err) := textmangle->read(sys->fildes(0));
	if(err != nil)
		fail(err);

	m := textmangle->parse(l);
	if(lflag) {
		hl := textmangle->toc(m);
		for(; hl != nil; hl = tl hl) {
			indent := "";
			for(i := 0; i < (hd hl).level; i++)
				indent += "#";
			sys->fprint(sys->fildes(2), "%s %s\n", indent, (hd hl).s);
		}
	}

	s: string;
	case format {
	"html" =>	s = textmangle->tohtml(m);
	"htmlpre" =>	s = textmangle->tohtmlpre(m);
	"text" =>	s = textmangle->totext(m);
	"latex" =>	s = "\\documentclass{article}\n\\begin{document}\n\n"+textmangle->tolatex(m)+"\n\\end{document}\n";
	"troff" =>	s = textmangle->totroff(m);
	* =>
		fail("bad format?");
	}
	sys->print("%s\n", s);
}

isformat(s: string): int
{
	for(i := 0; i < len formats; i++)
		if(formats[i] == s)
			return 1;
	return 0;
}

warn(s: string)
{
	sys->fprint(sys->fildes(2), "%s\n", s);
}

say(s: string)
{
	if(dflag)
		warn(s);
}

fail(s: string)
{
	warn(s);
	raise "fail:"+s;
}
