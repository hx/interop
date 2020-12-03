package interop

type bgRunner struct {
	runner interface {
		Run() error
	}
	blocker chan struct{}
	err     error
}

// Start calls the receiver's Run command in a new goroutine. Wait will block and return its error when it finishes.
func (b *bgRunner) Start() {
	if b.runner == nil {
		panic("nothing to start")
	}
	b.blocker = make(chan struct{})
	go func() {
		b.err = b.runner.Run()
		close(b.blocker)
	}()
}

// Wait for the process to finish running in the background, returning its error. Panics unless Start has been called.
func (b *bgRunner) Wait() error {
	<-b.blocker
	return b.err
}
