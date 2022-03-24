function savePlot(name,f)
    f.PaperType = 'a2';
    f.PaperOrientation = 'landscape';
    print(name,'-dpdf','-fillpage');
end

