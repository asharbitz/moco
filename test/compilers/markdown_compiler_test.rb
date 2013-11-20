require 'test_helper'

module MoCo

  describe MarkdownCompiler do

    after { reset_options(MarkdownCompiler) }

    let(:markdown) { '#Title' }
    let(:compiler) { mock_compiler(MarkdownCompiler, markdown) }
    let(:compiled_text) { compiler.compiled_text.strip }

    it 'is registered for md and markdown files' do
      assert_equal MarkdownCompiler, MoCo.compiler_for('md')
      assert_equal MarkdownCompiler, MoCo.compiler_for('markdown')
    end

    it 'is a Html compiler' do
      assert MarkdownCompiler < HtmlCompiler
      assert_equal 'html', MarkdownCompiler.compiled_extension
    end

    it 'compiles markdown into html' do
      assert_equal '<h1>Title</h1>', compiled_text
    end

    specify 'the options are used to specify markdown extensions' do
      MarkdownCompiler.set_option(:space_after_headers)
      assert_equal '<p>#Title</p>', compiled_text
    end

    specify 'the options are passed on to the html renderer' do
      MarkdownCompiler.set_option(:with_toc_data)
      assert_equal '<h1 id="toc_0">Title</h1>', compiled_text
    end

    describe 'the :smarty option' do

      before { MarkdownCompiler.set_option(:smarty) }

      let(:markdown) { '# ...' }

      it 'performs SmartyPants substitutions' do
        assert_equal '<h1>&hellip;</h1>', compiled_text
      end

      it 'works with the Pygments renderer' do
        MarkdownCompiler.set_option(:pygments)
        assert_equal '<h1>&hellip;</h1>', compiled_text
      end

      it 'works with the table of contents renderer' do
        MarkdownCompiler.set_option(:toc)
        assert_match '<a href="#toc_0">&hellip;</a>', compiled_text
      end

    end

    describe 'the :toc option' do

      before { MarkdownCompiler.set_option(:toc) }

      it 'produces a table of contents' do
        assert_match '<a href="#toc_0">Title</a>', compiled_text
        assert_match '<h1 id="toc_0">Title</h1>',  compiled_text
      end

    end

    describe 'the :layout option' do

      before { MarkdownCompiler.set_option(:layout, layout_file) }

      let(:layout_file) { fixtures_path('layout.html') }
      let(:layout) { File.read(layout_file) }

      it 'replaces {{BODY}} with the rendered markdown' do
        assert_match '<article>{{BODY}}</article>',         layout
        assert_match "<article><h1>Title</h1>\n</article>", compiled_text
      end

      describe '{{TOC}}' do

        before { MarkdownCompiler.set_option(:toc) }

        it 'replaces {{TOC}} with the table of contents' do
          assert_match '<nav>{{TOC}}</nav>',       layout
          assert_match "<nav><ul>\n<li>\n<a href", compiled_text
        end

        it 'removes {{TOC}} if there is no table of contents' do
          MarkdownCompiler.set_option(:toc, false)
          assert_match '<nav></nav>', compiled_text
        end

        it 'adds the toc to the {{BODY}} if there is no {{TOC}} tag' do
          layout_file = tmp_dir + '/layout.html'
          FileUtil.write(layout_file, layout.sub('{{TOC}}', ''))

          MarkdownCompiler.set_option(:layout, layout_file)
          assert_match "<article><ul>\n<li>\n<a href=", compiled_text
          assert_match "Title</h1>\n</article>",        compiled_text
        end

      end

      describe '{{TITLE}}' do

        it 'replaces {{TITLE}} with the first h1 element' do
          assert_match '<title>{{TITLE}}</title>', layout
          assert_match '<title>Title</title>',     compiled_text
        end

        it 'accepts an h1 element with attributes' do
          MarkdownCompiler.set_option(:toc)
          assert_match '<title>Title</title>', compiled_text
        end

        it 'removes nested tags from the title' do
          markdown = '# The [![Home](logo.png)](/index.html) Title'
          compiler = mock_compiler(MarkdownCompiler, markdown)
          assert_match '<title>The Title</title>', compiler.compiled_text
        end

        it 'replaces {{TITLE}} with the filename if there are no h1 elements' do
          compiler = mock_compiler(MarkdownCompiler, '## h2')
          assert_match '<title>mock.md</title>', compiler.compiled_text
        end

      end

      it 'replaces {{FILE}} with the filename' do
        assert_match '<span>{{FILE}}</span>', layout
        assert_match '<span>mock.md</span>',  compiled_text
      end

    end

    describe 'the :pygments option' do

      before { MarkdownCompiler.set_option(:pygments) }

      def code_block(statement, language)
        code_block = "```#{language}\n#{statement}\n```"
        mock_compiler(MarkdownCompiler, code_block).compiled_text.strip
      end

      it 'adds syntax highlighting hooks to fenced code blocks' do
        expected = '<div class="highlight"><pre><span class="nb">puts</span>'
        assert_match expected, code_block('puts', 'RUBY')
      end

      it 'ignores code blocks with no language specified' do
        expected = "<pre><code>puts\n</code></pre>"
        assert_equal expected, code_block('puts', nil)
      end

      it 'adds a class for unknown languages' do
        expected = "<pre><code class=\"dummy\">puts\n</code></pre>"
        assert_equal expected, code_block('puts', 'dummy')
      end

      it 'escapes the html' do
        expected = '&quot;&#39;&lt;&amp;&gt;'
        assert_match expected, code_block(%("'<&>'"), 'ruby')
        assert_match expected, code_block(%("'<&>'"), nil)
      end

      describe 'the :pygments options are passed on to Pygments' do

        let(:markdown) { "```ruby\nputs\nputs\nputs\nputs\n\n```" }

        it 'accepts a Hash' do
          MarkdownCompiler.set_option(:pygments, :linenos => 'inline')
          assert_equal 'inline', MarkdownCompiler.options[:pygments][:linenos]
          assert_match '<span class="lineno">1</span>', compiled_text
        end

        it 'accepts an Array' do
          MarkdownCompiler.set_option(:pygments, [:hl_lines, 2, 3])
          assert_equal [2, 3], MarkdownCompiler.options[:pygments][:hl_lines]
          compiled_text.split(/\n/).each_with_index do |line, index|
            if [2, 3].include?(index + 1)
              assert_match '<span class="hll">', line
            else
              refute_match '<span class="hll">', line
            end
          end
        end

        it 'can set an option to false' do
          MarkdownCompiler.set_option(:pygments, ['stripnl', false])
          assert_equal false, MarkdownCompiler.options[:pygments]['stripnl']
          assert_match "\n\n</pre></div>", compiled_text
        end

        it 'can be repeated' do
          MarkdownCompiler.set_option(:pygments, 'noclasses')
          MarkdownCompiler.set_option(:pygments, ['style', 'vim'])
          assert_equal true,  MarkdownCompiler.options[:pygments]['noclasses']
          assert_equal 'vim', MarkdownCompiler.options[:pygments]['style']
          assert_match '<span style="color: #cd00cd">puts', compiled_text
        end

      end

    end

  end if run_compiler_tests?(MarkdownCompiler)

end
