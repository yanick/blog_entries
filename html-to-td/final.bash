$ xss --stylesheet HTML2TD snippet.xml 
html {
    div {
        attr { class => 'entry_info', };
        div {
            attr { style => 'float: right', };
            outs 'created: Sat, Dec 18 2010';
        };
    };
    div {
        p { outs 'Web applications typically have [..]'; };
        pre { attr { class => 'brush: plain', }; outs '[..]'; };
    };
};
