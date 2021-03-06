# NAME

Exporter::ConditionalSubs - Conditionally export subroutines

# VERSION

version v1.11.1

# SYNOPSIS

Allows subroutines to be conditionally exported.  If the condition
is satisfied, the subroutine will be exported as usual.  But if not,
the subroutine will be replaced with a stub that gets optimized away
by the compiler.  When stubbed out, not even the arguments to the
subroutine will get evaluated.

This allows for e.g. assertion-like behavior, where subroutine calls
can be left in the code but effectively ignored under certain conditions.

First create a module that `ISA` [Exporter::ConditionalSubs](https://metacpan.org/pod/Exporter%3A%3AConditionalSubs):

    package My::Assertions;

    require Exporter::ConditionalSubs;
    our @ISA = qw( Exporter::ConditionalSubs );

    our @EXPORT    = ();
    our @EXPORT_OK = qw( _assert_non_empty );

    sub _assert_non_empty
    {
        carp "Found empty value" unless length(shift // '') > 0;
    }

Then, specify an `-if` or `-unless` condition when `use`ing that module:

    package My::App;

    use My::Assertions qw( _assert_non_empty ), -if => $ENV{DEBUG};

    use My::MoreAssertions -unless => $ENV{RUNTIME} eq 'prod';

    # Coderefs work too:
    use My::OtherAssertions -if => sub { ... some logic ... };

    _assert_non_empty($foo);    # this subroutine call might be a no-op

This is a subclass of [Exporter](https://metacpan.org/pod/Exporter) and works just like it, with the
addition of support for the `-if` and `-unless` import arguments.

# SUBROUTINES

## import

Works like the [Exporter](https://metacpan.org/pod/Exporter) `import()` function, except that it checks
for an optional `-if` or `-unless` import arg, followed by either
a boolean, or a coderef that returns true/false.

If the condition evaluates to true for `-if`, or false for `-unless`,
then any subs are exported as-is.  Otherwise, any subs in `@EXPORT_OK`
are replaced with stubs that get optimized away by the compiler (with
one exception - see ["CAVEATS"](#caveats) below).

You can specify either `-if` or `-unless`, but not both.  Croaks if
both are specified, or if you specify the same option more than once.

# CAVEATS

This module uses [B::CallChecker](https://metacpan.org/pod/B%3A%3ACallChecker) and [B::Generate](https://metacpan.org/pod/B%3A%3AGenerate) under the covers
to optimize away the exported subroutines.  Loading one or the other
of those modules can potentially break test coverage metrics generated
by [Devel::Cover](https://metacpan.org/pod/Devel%3A%3ACover) in mysterious ways.

To avoid this problem, subroutines are never optimized away
if [Devel::Cover](https://metacpan.org/pod/Devel%3A%3ACover) is in use, and are always exported as-is
regardless of any `-if` or `-unless` conditions.  (You probably
want [Devel::Cover](https://metacpan.org/pod/Devel%3A%3ACover) to assess the coverage of your real exported
subroutines in any case.)

# SEE ALSO

[Exporter](https://metacpan.org/pod/Exporter)

[B::CallChecker](https://metacpan.org/pod/B%3A%3ACallChecker)

[B::Generate](https://metacpan.org/pod/B%3A%3AGenerate)

# ACKNOWLEDGEMENTS

Thanks to Grant Street Group [http://www.grantstreet.com](http://www.grantstreet.com) for funding
development of this code.

Thanks to Tom Christiansen (`<tchrist@perl.com>`) for help with the
symbol table hackery
and Larry Leszczynski, `<larryl at cpan.org>` for writing most of
the code.

Thanks to Zefram (`<zefram@fysh.org>`) for the pointer to his
[Debug::Show](https://metacpan.org/pod/Debug%3A%3AShow) hackery.

# AUTHOR

Grant Street Group <developers@grantstreet.com>

# COPYRIGHT AND LICENSE

This software is Copyright (c) 2015 - 2020 by Grant Street Group.

This is free software, licensed under:

    The Artistic License 2.0 (GPL Compatible)
