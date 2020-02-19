requires 'B::CallChecker';
requires 'B::Generate';

on test => sub {
    requires 'Pod::Coverage';
    requires 'Test::CheckManifest';
    requires 'Test::Pod';
    requires 'Test::Pod::Coverage';
};


on develop => sub {
    requires 'Dist::Zilla::PluginBundle::Author::GSG';
};
